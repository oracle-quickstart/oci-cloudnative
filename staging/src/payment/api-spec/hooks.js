const hooks = require('hooks');

// Setup database connection before Dredd starts testing
hooks.before("/paymentAuth > POST", function(transaction, done) {
    transaction.request.headers['Content-Type'] = 'application/json';
    transaction.request.body = JSON.stringify({
	"amount": 10.00
    });
    done();
});
