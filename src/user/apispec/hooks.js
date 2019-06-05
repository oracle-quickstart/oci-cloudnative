const hooks = require('hooks');

hooks.before("/login > GET", function(transaction, done) {
    transaction.skip = true;
    done();
});

hooks.before("/register > POST", function(transaction, done) {
    transaction.request.headers['Content-Type'] = 'application/json';
    transaction.request.body = JSON.stringify(
	{
	    "username": "testuser",
	    "password": "testpassword"
	}
    );
    done();
});

hooks.before("/addresses > POST", function(transaction, done) {
    transaction.request.headers['Content-Type'] = 'application/json';
    transaction.request.body = JSON.stringify(
	{
	    	"street": "teststreet",
	    	"number": "15",
	    	"country": "The Netherlands",
		"city": "Den Haag"
	}
    );
    done();
});

hooks.before("/cards > POST", function(transaction, done) {
    transaction.request.headers['Content-Type'] = 'application/json';
    transaction.request.body = JSON.stringify(
	{
	    	"longNum": "1111222233334444",
	    	"expires": "11/2020",
	    	"ccv": "123"
	}
    );
    done();
});
