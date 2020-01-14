/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const { MockServiceAbstract } = require('./abstract');

/**
 * Mocked newsletter subscribe function
 */
module.exports = class MockNewsletterSubscribeFunction extends MockServiceAbstract {

  constructor(router) {
    super(router, 'newsletter');
  }

  /**
   * setup when enabled
   */
  onEnabled() {
    // Nothing here.
  }

  /**
   * mock newsletter function middleware
   * @param {express.router} router 
   */
  middleware(router) {
    // subscribe
    router.post('/newsletter', (req, res) => res.sendStatus(200));
  }
}