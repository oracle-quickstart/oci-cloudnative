/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const { MockServiceAbstract } = require('./abstract');
const { MockDb } = require('../db');

/**
 * Mocked catalogue service
 */
module.exports = class MockCatalogueService extends MockServiceAbstract {

  constructor(router) {
    super(router, 'catalogue');
  }

  /**
   * setup when enabled
   */
  onEnabled() {
    // load data
    this.products = new MockDb(require('../data/mock_products.json'));
    this.categories = new MockDb(require('../data/mock_categories.json'));

    // replace method in common
    this.replaceCommon('getProduct', async sku => this.products.findById(sku));
  }

  /**
   * mock catalog service middleware
   * @param {express.router} router 
   */
  middleware(router) {
    // categories
    router.get('/categories', (req, res) => res.json(this.categories.all()));

    // catalogue products
    router.get('/catalogue', (req, res) => {
      const { size, offset } = req.query;
      res.json(this.products.find(null, size, offset));
    }).get('/catalogue/:sku', (req, res) => {
      const { sku } = req.params;
      res.json(this.products.findById(sku));
    });
  }
}