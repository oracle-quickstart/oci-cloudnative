/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const nock = require('nock');
const supertest = require('supertest');
const app = require('../../app');
const { SERVICE_URL } = require('./testConfig');

module.exports = {
  /**
   * Mock a service response
   * @see https://www.npmjs.com/package/nock
   */
  service: () => nock(SERVICE_URL),
  /**
   * Mock the api service with persistent agent
   * @see https://www.npmjs.com/package/supertest
   */
  client: () => supertest.agent(app),
  /**
   * Mock the api service
   * @see https://www.npmjs.com/package/supertest
   */
  app: () => supertest(app),
};
