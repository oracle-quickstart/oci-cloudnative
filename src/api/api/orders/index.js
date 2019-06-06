(function (){
  'use strict';

  var async     = require("async")
    , express   = require("express")
    , request   = require("request")
    , endpoints = require("../endpoints")
    , helpers   = require("../../helpers")
    , app       = express.Router()

  app.get("/orders", function (req, res, next) {
    // console.log("Request received with body: " + JSON.stringify(req.body));
    var logged_in = req.cookies.logged_in;
    if (!logged_in) {
      throw new Error("User not logged in.");
      return
    }

    var custId = helpers.getCustomerId(req, app.get('env'));
    async.waterfall([
        function (callback) {
          request(endpoints.ordersUrl + "/orders/search/customer?sort=orderDate,desc&custId=" + custId, function (error, response, body) {
            if (error) {
              return callback(error);
            }
            // console.log("Received response: " + JSON.stringify(body));
            if (response.statusCode == 404) {
              console.log("No orders found for user: " + custId);
              return callback(null, []);
            }
            callback(null, JSON.parse(body)._embedded.customerOrders);
          });
        }
    ],
    function (err, result) {
      if (err) {
        return next(err);
      }
      helpers.respondStatusBody(res, 201, JSON.stringify(result));
    });
  });

  app.get("/orders/*", function (req, res, next) {
    var url = endpoints.ordersUrl + req.url.toString();
    request.get(url).pipe(res);
  });

  app.post("/orders", function(req, res, next) {
    // console.log("Request received with body: " + JSON.stringify(req.body));
    var logged_in = req.cookies.logged_in;
    if (!logged_in) {
      throw new Error("User not logged in.");
      return
    }

    var custId = helpers.getCustomerId(req, app.get('env'));
    var cartId = helpers.getCartId(req);

    async.waterfall([
        function (callback) {
          request(endpoints.customersUrl + "/" + custId, function (error, response, body) {
            if (error || body.status_code === 500) {
              callback(error);
              return;
            }
            // console.log("Received response: " + JSON.stringify(body));
            var jsonBody = JSON.parse(body);
            var customerlink = jsonBody._links.customer.href;
            var addressLink = jsonBody._links.addresses.href;
            var cardLink = jsonBody._links.cards.href;
            var order = {
              "customer": customerlink,
              "address": null,
              "card": null,
              "items": endpoints.cartsUrl + "/" + cartId + "/items"
            };
            callback(null, order, addressLink, cardLink);
          });
        },
        function (order, addressLink, cardLink, callback) {
          async.parallel([
              function (callback) {
                // console.log("GET Request to: " + addressLink);
                request.get(addressLink, function (error, response, body) {
                  if (error) {
                    callback(error);
                    return;
                  }
                  // console.log("Received response: " + JSON.stringify(body));
                  var jsonBody = JSON.parse(body);
                  if (jsonBody.status_code !== 500 && jsonBody._embedded.address.length) {
                    order.address = jsonBody._embedded.address.pop()._links.self.href;
                  }
                  callback();
                });
              },
              function (callback) {
                // console.log("GET Request to: " + cardLink);
                request.get(cardLink, function (error, response, body) {
                  if (error) {
                    callback(error);
                    return;
                  }
                  // console.log("Received response: " + JSON.stringify(body));
                  var jsonBody = JSON.parse(body);
                  if (jsonBody.status_code !== 500 && jsonBody._embedded.card.length) {
                    order.card = jsonBody._embedded.card.pop()._links.self.href;
                  }
                  callback();
                });
              }
          ], function (err, result) {
            if (err) {
              callback(err);
              return;
            }
            console.log(result);
            callback(null, order);
          });
        },
        function (order, callback) {
          var options = {
            uri: endpoints.ordersUrl + '/orders',
            method: 'POST',
            json: true,
            body: order
          };
          console.log("Posting Order: " + JSON.stringify(order));
          request(options, function (error, response, body) {
            if (error) {
              return callback(error);
            }
            console.log("Order response: " + JSON.stringify(response));
            console.log("Order response: " + JSON.stringify(body));
            callback(null, response.statusCode, body);
          });
        }
    ],
    function (err, status, result) {
      if (err) {
        return next(err);
      }
      helpers.respondStatusBody(res, status, JSON.stringify(result));
    });
  });

  module.exports = app;
}());
