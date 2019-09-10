/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
(function (){
  'use strict';

  const axios = require('axios');
  const ulid = require("ulid");
  const helpers = {};

  const [ COOKIE_NAME, COOKIE_TTL ] = [ 'logged_in', 3.6e6 ];

  /* Public: errorHandler is a middleware that handles your errors
   *
   * Example:
   *
   * var app = express();
   * app.use(helpers.errorHandler);
   * */
  helpers.errorHandler = function(err, req, res, next) {
    const ret = {
      message: err.message,
      error:   err.toString(),
    };
    res.status(err.status || 500).json(ret);
  };

  /**
   * Error with status code
   */
  helpers.createError = function(err, status) {
    const e = err instanceof Error ? err : new Error(err);
    e.status = status;
    return e;
  };

  /**
   * handle session logic
   */
  helpers.sessionMiddleware = function(req, res, next) {
    if (!helpers.isLoggedIn(req)) {
      req.session.customerId = null;
    }
    next();
  };

  /* Responds with the given body and status 200 OK  */
  helpers.respondSuccessBody = function(res, body) {
    helpers.respondStatusBody(res, 200, body);
  };

  /* Public: responds with the given body and status
   *
   * res        - response object to use as output
   * statusCode - the HTTP status code to set to the response
   * body       - (string) the body to yield to the response
   */
  helpers.respondStatusBody = function(res, statusCode, body) {
    res.status(statusCode).send(body);
  };

  /* Responds with the given statusCode */
  helpers.respondStatus = function(res, statusCode) {
    res.status(statusCode).send();
  };

  /* Rewrites and redirects any url that doesn't end with a slash. */
  helpers.rewriteSlash = function(req, res, next) {
   if(req.url.substr(-1) == '/' && req.url.length > 1)
       res.redirect(301, req.url.slice(0, -1));
   else
       next();
  };

  /* Public: performs an HTTP GET request to the given URL
   *
   * url  - the URL where the external service can be reached out
   * res  - the response object where the external service's output will be yield
   * next - callback to be invoked in case of error. If there actually is an error
   *        this function will be called, passing the error object as an argument
   *
   * Examples:
   *
   * app.get("/users", function(req, res) {
   *   helpers.simpleHttpRequest("http://api.example.org/users", res, function(err) {
   *     res.send({ error: err });
   *     res.end();
   *   });
   * });
   */
  helpers.simpleHttpRequest = function(url, res, next) {
    return axios.get(url)
      .then(({status, data}) => res.status(status).json(data))
      .catch(next);
  };

  /**
   * Get unique cart identifier for the session
   * @param {object} req - express request
   */
  helpers.getCartId = function(req) {
    var cartId = req.session.cartId || ulid.ulid();
    req.session.cartId = cartId;
    return cartId;
  };

  /**
   * Check for authenticated user
   */
  helpers.isLoggedIn = function(req) {
    const { [COOKIE_NAME]: logged_in } = req.cookies;
    return !!logged_in;
  };

  helpers.setAuthenticated = function(req, res, userId) {
    if (userId) {
      const sessionId = req.session.id;
      req.session.customerId = userId;
      res.cookie(COOKIE_NAME, sessionId, { maxAge: COOKIE_TTL });
    } else {
      // logout
      req.session.customerId = null;
      req.session.cartId = null;
      res.cookie(COOKIE_NAME, '', { expires: new Date(0) });
    }
    return res;
  };

  /* TODO: Add documentation */
  helpers.getCustomerId = function(req) {
    // Check if logged in. Get customer Id
    const { id, customerId } = req.session;

    if (!helpers.isLoggedIn(req)) {
      if (!id) {
        throw new Error("User not logged in.");
      }
      // Use Session ID instead
      return id;
    }

    return customerId;
  };
  module.exports = helpers;
}());
