(function () {
  'use strict';

  // getEnvVar returns the environment variable value or throws if the variable is not set
  function getEnvVar(name) {
    const value = process.env[name];
    if (null == value) {
      throw new Error(`Environment variable ${name} is not set.`);
    }
    return value;
  }

  const catalogueUrl = getEnvVar("CATALOGUE_URL");
  const cartsUrl = getEnvVar("CARTS_URL");
  const ordersUrl = getEnvVar("ORDERS_URL");
  const usersUrl = getEnvVar("USERS_URL");

  module.exports = {
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
