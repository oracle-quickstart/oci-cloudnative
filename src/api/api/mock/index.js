/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
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