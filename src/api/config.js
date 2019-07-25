(function (){
  'use strict';
  
  require('dotenv').config();

  var session      = require("express-session"),
      RedisStore   = require('connect-redis')(session);

  module.exports = {
    env: function(key) {
      return key ? process.env[key] : process.env;
    },
    session: function() {
      const { SESSION_REDIS, SESSION_SECRET } = this.env();

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
