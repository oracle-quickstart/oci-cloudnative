const hooks = require('hooks');

// Mock connection
hooks.before("/events > POST", (transaction, done) => {
    transaction.request.headers['Content-Type'] = 'application/json';
    transaction.request.body = JSON.stringify({
      type: 'client',
      track: 'abcxyz',
      events: [{
        type: 'view',
        details: {
          page: 'product',
          id: 'MU-US-001',
        }
      }],
    });
    done();
});
