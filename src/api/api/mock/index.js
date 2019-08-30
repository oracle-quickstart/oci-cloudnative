
const express = require("express");
const Service = require('./service');

/**
 * MuShop "offline" mock middleware
 */
class MockMiddleware {

  constructor() {
    this._router = express.Router();
    // create a hash of each service mock
    this.mocks = Object.assign({}, ...[
        Service.MockCartsService,
        Service.MockCatalogueService,
        Service.MockOrdersService,
        Service.MockUsersService,
      ].map(ctor => new ctor(this._router))
      .map(impl => ({[impl.service]: impl}))
    );
  }
  
  /**
   * Public getter for the mocked layers
   */
  layer() {
    return this._router;
  }
}

module.exports = new MockMiddleware();