(function() {
    'use strict';


    const axios = require("axios")
      , express = require("express")
      , app = express.Router()
      , endpoints = require("../endpoints")
      , helpers = require("../../helpers")
      , mock = require("../../helpers/mock")

    const [ COOKIE_NAME, COOKIE_TTL ] = [ 'logged_in', 3.6e6 ];

    app.get("/profile", function(req, res, next) {
        const userId = helpers.getCustomerId(req, app.get("env"));
        helpers.simpleHttpRequest(endpoints.customersUrl + "/" + userId, res, next);
    });
    app.get("/customers/:id", function(req, res, next) {
        const { id } = req.params;
        const userId = helpers.getCustomerId(req, app.get("env"));
        if (~~id === ~~userId) {
            helpers.simpleHttpRequest(endpoints.customersUrl + "/" + userId, res, next);
        } else {
            res.status(401).end();
        }
    });
    app.get("/cards/:id", function(req, res, next) {
        helpers.simpleHttpRequest(endpoints.cardsUrl + "/" + req.params.id, res, next);
    });

    // Designed to be blocked by WAF
    app.get("/customers", function(req, res) {
        // helpers.simpleHttpRequest(endpoints.customersUrl, res, next);
        res.json(mock.response('customer', mock.Customers));
    });
    app.get("/addresses", function(req, res) {
        // helpers.simpleHttpRequest(endpoints.addressUrl, res, next);
        res.json(mock.response('address', mock.Addresses));
    });
    app.get("/cards", function(req, res) {
        // helpers.simpleHttpRequest(endpoints.cardsUrl, res, next);
        res.json(mock.response('card', mock.Cards));
    });

    // Create an address
    app.post("/address", function(req, res, next) {
        req.body.userID = helpers.getCustomerId(req, app.get("env"));

        axios.post(endpoints.addressUrl, req.body)
            .then(({ data }) => res.json(data))
            .catch(next);
    });

    // get a single address
    app.get("/address", function(req, res, next) {
        var custId = helpers.getCustomerId(req, app.get("env"));
        axios.get(endpoints.customersUrl + '/' + custId + '/addresses')
            .then(({ data }) => {
                if (data.status_code !== 500 && data._embedded.address && data._embedded.address.length ) {
                    const addr = data._embedded.address.pop();
                    return res.json(addr);
                }
                return res.json({ status_code: 500 });
            }).catch(next);
    });

    // Fetch a single card
    app.get("/card", function(req, res, next) {
        var custId = helpers.getCustomerId(req, app.get("env"));
        axios.get(endpoints.customersUrl + '/' + custId + '/cards')
            .then(({ data }) => {
                if (data.status_code !== 500 && data._embedded.card && data._embedded.card.length ) {
                    const card = data._embedded.card.pop(); // last 
                    return res.json({
                        id: card.id,
                        expires: card.expires,
                        number: card.longNum.slice(-4),
                    });
                }
                // TODO: deprecate 200 => 500 in client
                return res.json({ status_code: 500 });
            }).catch(next);
    });

    // create a stored card
    app.post("/card", function(req, res, next) {
        req.body.userID = helpers.getCustomerId(req, app.get("env"));
        axios.post(endpoints.cardsUrl, req.body)
            .then(({data}) => res.json(data))
            .catch(next);
    });

    // Delete Customer - TO BE USED FOR TESTING ONLY (for now)
    app.delete("/customers/:id", function(req, res, next) {
        axios.delete(endpoints.customersUrl + "/" + req.params.id)
            .then(({data}) => res.json(data))
            .catch(next);
    });

    // Delete Address
    app.delete("/addresses/:id", function(req, res, next) {
        axios.delete(endpoints.addressUrl + "/" + req.params.id)
            .then(({data}) => res.json(data))
            .catch(next);
    });

    // Delete Card - TO BE USED FOR TESTING ONLY (for now)
    app.delete("/cards/:id", function(req, res, next) {
        axios.delete(endpoints.cardsUrl + "/" + req.params.id)
            .then(({data}) => res.json(data))
            .catch(next);
    });

    app.post("/register", async (req, res, next) => {
        try {
            const { data: user } = await axios.post(endpoints.registerUrl, req.body);

            const sessionId = req.session.id;
            req.session.customerId = user.id;

            // TODO: fix merge cart
            // const cartId = helpers.getCartId(req);
            // await axios.get(`${endpoints.cartsUrl}/${user.id}/merge?sessionId=${sessionId}`).catch(() => {/* noop */});

            res.status(200)
                .cookie(COOKIE_NAME, sessionId, { maxAge: COOKIE_TTL})
                .json({ id: user.id });

        } catch (e) {
            next(e);
        }
    });

    app.get("/login", async (req, res, next) => {
        try {
            // do auth
            const { data: { user } } = await axios.get(endpoints.loginUrl, {
                headers: {
                    authorization: req.get('authorization'),
                }
            });

            const sessionId = req.session.id;
            req.session.customerId = user.id;

            // TODO: fix merge cart
            // const cartId = helpers.getCartId(req);
            // await axios.get(`${endpoints.cartsUrl}/${user.id}/merge?sessionId=${sessionId}`).catch(() => {/* noop */});

            res.status(200)
                .cookie(COOKIE_NAME, sessionId, { maxAge: COOKIE_TTL})
                .send('OK');
        } catch (e) {
            res.status(401).end();
        }

    });

    app.get('/logout', (req, res) => {
        req.session.customerId = null;
        req.session.cartId = null;
        res.cookie(COOKIE_NAME, '', {expires: new Date(0)});
        helpers.respondStatus(res, 200);
    });

    module.exports = app;
}());
