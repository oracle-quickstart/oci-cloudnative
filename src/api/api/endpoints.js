(function () {
  'use strict';

  const { env, keyMap } = require('../config');

  // getEnvVar returns the environment variable value or throws if the variable is not set
  function getEnvVar(name) {
    const value = env(name);
    if (null == value) {
      throw new Error(`Environment variable ${name} is not set.`);
    }
    return value;
  }

  const { services } = keyMap();

  const catalogueUrl = getEnvVar(services.CATALOG);
  const cartsUrl = getEnvVar(services.CARTS);
  const ordersUrl = getEnvVar(services.ORDERS);
  const usersUrl = getEnvVar(services.USERS);

  module.exports = {
    getEnvVar, // for testing
    catalogueUrl,
    ordersUrl,
    cartsUrl: `${cartsUrl}/carts`,
    customersUrl: `${usersUrl}/customers`,
    addressUrl: `${usersUrl}/addresses`,
    cardsUrl: `${usersUrl}/cards`,
    loginUrl:  `${usersUrl}/login`,
    registerUrl:  `${usersUrl}/register`,
  };
}());
