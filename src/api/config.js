(function (){
  'use strict';

  var session      = require("express-session"),
      RedisStore   = require('connect-redis')(session);

  module.exports = {
    session: function() {
      
      const { SESSION_REDIS } = process.env;

      if (!!SESSION_REDIS) {
        console.log('Using the redis based session manager');
      }

      return {
        store: SESSION_REDIS && new RedisStore({ host: SESSION_REDIS }),
        name: 'mu.sid',
        secret: 'sooper secret',
        resave: false,
        saveUninitialized: true
      }
    },
  };
}());
