const nock = require('nock');
const { SERVICE_URL } = require('./testConfig');

module.exports = {
  mockService: () => nock(SERVICE_URL),
};