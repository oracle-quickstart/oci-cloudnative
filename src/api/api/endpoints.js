/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
(function () {
  'use strict';

  const config = require('../config');

  // getEnvVar returns the environment variable value or throws if the variable is not set
  function getEnvVar(name, required) {
    const value = config.env(name);
    if (null == value && required) {
      throw new Error(`Environment variable ${name} is not set.`);
    }
    return value;
  }

  const { services } = config.keyMap();

  const catalogueUrl = getEnvVar(services.CATALOG, !config.mockMode('catalogue'));
  const cartsUrl = getEnvVar(services.CARTS, !config.mockMode('carts'));
  const ordersUrl = getEnvVar(services.ORDERS, !config.mockMode('orders'));
  const usersUrl = getEnvVar(services.USERS, !config.mockMode('users'));
  const newsletterSubscribeUrl = getEnvVar(services.NEWSLETTER_SUBSCRIBE, false);

  module.exports = {
    getEnvVar, // for testing
    catalogueUrl,
    ordersUrl,
    cartsUrl: `${cartsUrl}/carts`,
    customersUrl: `${usersUrl}/customers`,
    loginUrl:  `${usersUrl}/login`,
    registerUrl:  `${usersUrl}/register`,
    newsletterSubscribeUrl,
  };
}());
