
const config = require('../../../config');
const common = require('../../common');

/**
 * abstraction for mock services
 */
class MockServiceAbstract {
  /**
   * create mock service instance
   * @param {*} router - the mock router
   * @param {*} service - name of the service to mock
   * @param  {...string} dependencies - services that would also force this into mock mode
   */
  constructor(router, service, ...dependencies) {
    this.service = service;
    this.enabled = config.mockMode(dependencies.concat(service));
    if (this.enabled) {
      console.log(`MOCK mode: ${service.toUpperCase()}`);
      this.onEnabled();
      this.middleware(router);
    }
  }

  /**
   * optional method called when the service is mocked
   */
  onEnabled() {

  }

  /**
   * Method for attaching mocked middleware once enabled.
   * @param {*} router 
   */
  middleware(router) {
    throw new Error('Mocked service must implement a router');
  }

  /**
   * Replace a common method with a new implementation due to the service mocking
   * @param {string} method 
   * @param {Function<Promise>} implementation 
   */
  replaceCommon(method, implementation) {
    common[method] = implementation;
  }
}

module.exports = {
  MockServiceAbstract,
};
