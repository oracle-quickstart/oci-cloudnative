/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

const { env, keyMap } = require('../../config');
const { SERVICE_URL, PORT } = require('./testConfig');

module.exports = async () => {
  // Assign each service url in the env
  const { services } = keyMap();
  Object.assign(env(), ...Object.values(services).map(key => ({
    [key]: SERVICE_URL,
  })));

  // Assign port for server in test
  env().PORT = PORT;
};
