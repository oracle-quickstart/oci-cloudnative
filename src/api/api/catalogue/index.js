(function () {
  'use strict';

  const axios = require("axios")
    , express = require("express")
    , endpoints = require("../endpoints")
    , helpers = require("../../helpers")
    , app = express.Router();

  app.get("/catalogue/images*", function (req, res, next) {
    const url = endpoints.catalogueUrl + req.url.toString();
    axios.get(url, { responseType: 'stream' })
      .then(response => response.data.pipe(res))
      .catch(next);
  });

  app.get("/catalogue*", function (req, res, next) {
    helpers.simpleHttpRequest(endpoints.catalogueUrl + req.url.toString(), res, next);
  });

  app.get("/categories", function (req, res, next) {
    helpers.simpleHttpRequest(endpoints.catalogueUrl + req.url.toString(), res, next);
  });

  module.exports = app;
}());
