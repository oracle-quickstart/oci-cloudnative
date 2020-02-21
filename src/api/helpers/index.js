/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
(function () {
  'use strict';

  const axios = require('axios');
  const ulid = require('ulid');
  const endpoints = require('../api/endpoints');
  const helpers = {};

  const [COOKIE_NAME, COOKIE_TTL] = ['logged_in', 3.6e6];

  const traceHeaders = [
    // Tracing headers
    'x-request-id',
    'x-b3-traceid',
    'x-b3-spanid',
    'x-b3-parentspanid',
    'x-b3-sampled',
    'x-b3-flags',
    'x-ot-span-context',

    // Additional headers to pass: can be used for traffic routing later
    'x-user',
    'user-agent',
  ];

  /* Public: errorHandler is a middleware that handles your errors
   *
   * Example:
   *
   * var app = express();
   * app.use(helpers.errorHandler);
   * */
  helpers.errorHandler = function (err, req, res, next) {
    const { response } = err;
    const status = (response && response.status) || err.status || 500;
    const ret = {
      message: response ? response.statusText : err.message,
      error: err.toString(),
    };
    res.status(status).json(ret);
  };

  /**
   * Error with status code
   */
  helpers.createError = function (err, status) {
    const e = err instanceof Error ? err : new Error(err);
    e.status = status;
    return e;
  };

  /**
   * handle session logic
   */
  helpers.sessionMiddleware = function (req, res, next) {
    if (!helpers.isLoggedIn(req)) {
      req.session.customerId = null;
    }
    next();
  };

  /* Responds with the given body and status 200 OK  */
  helpers.respondSuccessBody = function (res, body) {
    helpers.respondStatusBody(res, 200, body);
  };

  /* Public: responds with the given body and status
   *
   * res        - response object to use as output
   * statusCode - the HTTP status code to set to the response
   * body       - (string) the body to yield to the response
   */
  helpers.respondStatusBody = function (res, statusCode, body) {
    res.status(statusCode).send(body);
  };

  /* Responds with the given statusCode */
  helpers.respondStatus = function (res, statusCode) {
    res.status(statusCode).send();
  };

  /* Rewrites and redirects any url that doesn't end with a slash. */
  helpers.rewriteSlash = function (req, res, next) {
    if (req.url.substr(-1) == '/' && req.url.length > 1)
      res.redirect(301, req.url.slice(0, -1));
    else next();
  };

  /**
   * Get unique cart identifier for the session
   * @param {object} req - express request
   */
  helpers.getCartId = function (req) {
    var cartId = req.session.cartId || ulid.ulid();
    req.session.cartId = cartId;
    return cartId;
  };

  /**
   * Check for authenticated user
   */
  helpers.isLoggedIn = function (req) {
    const { [COOKIE_NAME]: logged_in } = req.cookies;
    return !!logged_in;
  };

  helpers.setAuthenticated = function (req, res, userId) {
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
  helpers.getCustomerId = function (req) {
    // Check if logged in. Get customer Id
    const { id, customerId } = req.session;

    if (!helpers.isLoggedIn(req)) {
      if (!id) {
        throw new Error('User not logged in.');
      }
      // Use Session ID instead
      return id;
    }

    return customerId;
  };

  /**
   * provide http client getter that returns an axios instance
   * with tracing and tracking interceptors
   */
  helpers.svcClientMiddleware = function(req, res, next) {

    // create passthrough tracing headers
    const headers = Object.assign({}, ...traceHeaders
      .filter(h => req.get(h))
      .map(h => ({[h]: req.get(h)})));

    /**
     * http client getter resolves an instance with track method
     */
    req.svcClient = (trackEvent) => {
      // create client
      const client = req._svcClient = req._svcClient || axios.create({ headers });
      if (trackEvent) {
        // add tracking interceptor
        const intercept = client.interceptors.response.use(
          async response => { await tracker(trackEvent, response.data); return response; },
          async err => { await tracker(trackEvent + ':error', { status: err.response.status, ...err.response.data }); throw err; },
        );
        // track and eject intercept
        const tracker = (type, detail) => {
          client.interceptors.response.eject(intercept); // clear the interceptor
          return helpers.trackEvents(req, { events: [{type, detail}] });
        };
      }
      return client;
    };
    
    next();
  };

  /**
   * get/create a tracking identifier for the session
   */
  helpers.getTrackingId = function(req) {
    req.session.trackId = req.session.trackId || ulid.ulid();
    return req.session.trackId;
  };

  /**
   * event tracking function
   */
  helpers.trackEvents = async function (req, payload) {
    const { eventsUrl } = endpoints;
    if (!!eventsUrl) {
      payload.source = payload.source || 'api';
      // tracking id
      payload.track = payload.track || helpers.getTrackingId(req);
      // ensure timestamp
      (payload.events || [])
        .forEach(evt => evt.time = evt.time || new Date().toISOString());
      
      return await req.svcClient()
        .post(eventsUrl, payload)
        .catch(() => {/* always noop */});
    }
  };
  module.exports = helpers;
})();
