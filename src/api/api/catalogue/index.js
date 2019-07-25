(function () {
  'use strict';

  var express = require("express")
    , request = require("request")
    , endpoints = require("../endpoints")
    , helpers = require("../../helpers")
    , app = express.Router()

  app.get("/catalogue/images*", function (req, res, next) {
    var url = endpoints.catalogueUrl + req.url.toString();
    request.get(url)
      .on('error', function (e) { next(e); })
      .pipe(res);
  });

  app.get("/catalogue*", function (req, res, next) {
    helpers.simpleHttpRequest(endpoints.catalogueUrl + req.url.toString(), res, next);
  });

  app.get("/categories", function (req, res, next) {
    helpers.simpleHttpRequest(endpoints.catalogueUrl + req.url.toString(), res, next);
  });

  module.exports = app;
}());
