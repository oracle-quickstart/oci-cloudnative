/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
(function (){
  'use strict';
  const apiRoutes = ['cart', 'catalogue', 'orders', 'user'];
  const express = require("express")
      , client  = require('prom-client')
      , app     = express.Router()

  const metric = {
    http: {
      requests: {
        duration: new client.Histogram({
          name: 'http_request_duration_seconds',
          help: 'request duration in seconds',
          labelNames: ['service', 'method', 'path', 'status_code'],
        }),
      }
    }
  };

  function s(start) {
    var diff = process.hrtime(start);
    return (diff[0] * 1e9 + diff[1]) / 1000000000;
  }

  function observe(method, path, statusCode, start) {
    var route = path.toLowerCase();
    var duration = s(start);
    var method = method.toLowerCase();
    metric.http.requests.duration.labels('api', method, route, statusCode).observe(duration);
  };

  /**
   * metrics middleware
   * @param {express.Request} req 
   * @param {express.Response} res 
   * @param {NextFunction} next 
   */
  function middleware(req, res, next) {
    var start = process.hrtime();

    res.on('finish', function() {
      // Only log API routes, and only record the backend service name (no unique identifiers)
      var model = req.path
        .replace('/api/', '/')
        .split('/')[1];
      if (apiRoutes.indexOf(model) !== -1) {
        observe(req.method, model, res.statusCode, start);
      }

    });

    return next();
  };

  app.use(middleware);


  /**
   * metrics collection endpoint
   */
  app.get("/metrics", function(req, res) {
    const { register } = client;
    const data = register.metrics();
    res.set('Content-Type', register.contentType).send(data);
  });

  module.exports = app;
}());
