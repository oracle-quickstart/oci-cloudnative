// const nock = require('nock');
const { env, keyMap } = require('../../config');
const { SERVICE_URL, PORT } = require('./testConfig');

module.exports = async () => {
  // Assign each service url in the env
  const { services } = keyMap();
  Object.assign(env(), ...Object.values(services).map(key => ({
    [key]: SERVICE_URL,
  })));

  // Assign port for services
  env().PORT = PORT;
};
