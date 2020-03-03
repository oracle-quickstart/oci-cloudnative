/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
(function () {
  'use strict';

  const express = require("express"),
    endpoints = require("../endpoints"),
    app = express.Router();

  app.get("/catalogue/images*", function (req, res, next) {
    const url = endpoints.catalogueUrl + req.url.toString();
    req.svcClient().get(url, { responseType: 'stream' })
      .then(response => response.data.pipe(res))
      .catch(next);
  });

  app.get("/catalogue*", function (req, res, next) {
    req.svcClient()
      .get(endpoints.catalogueUrl + req.url.toString())
      .then(({ data }) => res.json(data))
      .catch(next);
  });

  app.get("/categories", function (req, res, next) {
    req.svcClient()
      .get(endpoints.catalogueUrl + req.url.toString())
      .then(({ data }) => res.json(data))
      .catch(next);
  });

  module.exports = app;
}());
