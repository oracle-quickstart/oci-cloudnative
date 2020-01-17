/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
(function (){
  'use strict';
  
  require('dotenv').config();

  var session      = require("express-session"),
      RedisStore   = require('connect-redis')(session);

  const sessionKeyMap = {
    REDIS: 'SESSION_REDIS',
    SECRET: 'SESSION_SECRET',
  };

  const serviceUrlKeyMap = {
    CATALOG: 'CATALOGUE_URL',
    CARTS: 'CARTS_URL',
    ORDERS: 'ORDERS_URL',
    USERS: 'USERS_URL',
    NEWSLETTER_SUBSCRIBE: 'NEWSLETTER_SUBSCRIBE_URL',
  };

  const settingKeyMap = {
    CDN: 'STATIC_MEDIA_URL',
  };

  module.exports = {
    env: function(key) {
      return key ? process.env[key] : process.env;
    },
    prod: function() {
      return /^prod/i.test(this.env('NODE_ENV') || '');
    },
    test: function() {
      return /^test/i.test(this.env('NODE_ENV') || '');
    },
    mockMode: function(service) {
      const mocks = (this.env('MOCK_MODE') || '').split(',').map(m => m.trim().toLowerCase());
      return ['true', 'all', '1'] // match all
        .concat(service || []) // match specific service
        .some(val => mocks.indexOf(val) > -1);
    },
    keyMap: function() {
      return {
        session: sessionKeyMap,
        services: serviceUrlKeyMap,
        setting: settingKeyMap,
      };
    },
    session: function() {
      const keys = this.keyMap().session;
      const {
        [keys.REDIS]: SESSION_REDIS,
        [keys.SECRET]: SESSION_SECRET,
      } = this.env();

      if (!!SESSION_REDIS) {
        console.log('Using the redis based session manager');
      }

      return {
        store: SESSION_REDIS && new RedisStore({ host: SESSION_REDIS }),
        secret: SESSION_SECRET || 'mustoresecret',
        name: 'mu.sid',
        resave: false,
        saveUninitialized: true
      };
    },
  };
}());
