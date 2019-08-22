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
    keyMap: function() {
      return {
        session: sessionKeyMap,
        services: serviceUrlKeyMap,
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
