(function () {
  'use strict';

  // getEnvVar returns the environment variable value or fails if the variable is not set
  function getEnvVar(name) {
    const value = process.env[name];
    if (!value) {
      throw new Error(`Environment variable ${name} is not set.`);
    }
    return value;
  }

  const catalogueBase = getEnvVar("CATALOGUE_URL");
  const cartsBase = getEnvVar("CARTS_URL");
  const ordersBase = getEnvVar("ORDERS_URL");
  const usersBase = getEnvVar("USERS_URL");

  var util = require('util');

  module.exports = {
    catalogueUrl: catalogueBase,
    tagsUrl: util.format("%s/tags", catalogueBase),
    cartsUrl: util.format("%s/carts", cartsBase),
    ordersUrl: ordersBase,
    customersUrl: util.format("%s/customers", usersBase),
    addressUrl: util.format("%s/addresses", usersBase),
    cardsUrl: util.format("%s/cards", usersBase),
    loginUrl: util.format("%s/login", usersBase),
    registerUrl: util.format("%s/register", usersBase),
  };
}());
