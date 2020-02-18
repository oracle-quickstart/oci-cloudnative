/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const hooks = require('hooks');

// Mock connection
hooks.before("/events > POST", (transaction, done) => {
    transaction.request.headers['Content-Type'] = 'application/json';
    transaction.request.body = JSON.stringify({
      source: 'client',
      track: 'abcxyz',
      events: [{
        type: 'pageView',
        detail: {
          page: 'product',
          productId: 'product-001',
        }
      }]
    });
    done();
});
