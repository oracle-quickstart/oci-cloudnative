/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
(function() {
    'use strict';


    const axios = require("axios")
      , express = require("express")
      , app = express.Router()
      , common    = require("../common")
      , endpoints = require("../endpoints")
      , helpers = require("../../helpers")
      , mock = require("../../helpers/mock");

    function profile(req, res) {
        common.getCustomer(req)
            .then(u => (u ? res.json(u) : Promise.reject('not authorized')))
            .catch(() => helpers.respondStatus(res, 401));
    }

    /**
     * user resource uri
     * @param {express.Request} req
     * @param {string} resource
     */
    function resourceUri(req, resource) {
        const custId = helpers.getCustomerId(req);
        return `${endpoints.customersUrl}/${custId}/${resource}`;
    }

    /**
     * Attempt to update cart with customerId if present.
     * @param {express.Request} req
     * @param {customerId} the customer id
     */
    async function updateCart(req, customerId) {
      const cartId = req.session.cartId;
      if (cartId) {
          await axios.post(endpoints.cartsUrl + "/" + cartId, {
            customerId: customerId
          });
      }
    }

    app.get("/profile", profile);

    app.get("/customers/:id", function(req, res, next) {
        const { id } = req.params;
        const userId = helpers.getCustomerId(req);
        if (~~id === ~~userId) {
            profile(req, res);
        } else {
            res.status(401).end();
        }
    });

    // Designed to be blocked by WAF
    app.get("/customers", function(req, res) {
        res.json(mock.response('customer', mock.Customers));
    });
    app.get("/addresses", function(req, res) {
        res.json(mock.response('address', mock.Addresses));
    });
    app.get("/cards", function(req, res) {
        res.json(mock.response('card', mock.Cards));
    });

    // Create an address
    app.post("/address", function(req, res, next) {
        axios.post(resourceUri(req, 'addresses'), req.body)
            .then(({ status, data }) => res.status(status).json(data))
            .catch(next);
    });

    // get a single address
    app.get("/address", function(req, res, next) {
        axios.get(resourceUri(req, 'addresses'))
            .then(({ data }) => res.json(data.pop()))
            .catch(next);
    });

    // Fetch a single card for the user
    app.get("/card", function(req, res, next) {
        axios.get(resourceUri(req, 'cards'))
            .then(({ data }) => res.json(data.pop()))
            .catch(next);
    });

    // create a stored card
    app.post("/card", function(req, res, next) {
        axios.post(resourceUri(req, 'cards'), req.body)
            .then(({ status, data }) => res.status(status).json(data))
            .catch(next);
    });

    // Delete Customer
    app.delete("/customers/:id", function(req, res, next) {
        axios.delete(endpoints.customersUrl + "/" + req.params.id)
            .then(({ status, data }) => res.status(status).json(data))
            .catch(next);
    });

    // Delete Address
    app.delete("/addresses/:id", function(req, res, next) {
        axios.delete(resourceUri(req, 'addresses') + "/" + req.params.id)
            .then(({ status, data }) => res.status(status).json(data))
            .catch(next);
    });

    // Delete Card
    app.delete("/cards/:id", function(req, res, next) {
        axios.delete(resourceUri(req, 'cards') + "/" + req.params.id)
            .then(({ status, data }) => res.status(status).json(data))
            .catch(next);
    });

    app.post("/register", async (req, res, next) => {
        try {
            const { status, data: user } = await axios.post(endpoints.registerUrl, req.body);
            await updateCart(req, user.id).catch();
            helpers.setAuthenticated(req, res, user.id)
                   .status(status)
                   .json({ id: user.id });
        } catch (e) {
            next(e);
        }
    });

    app.post("/login", async (req, res, next) => {
        try {
            // client uses basic-auth
            const auth = req.get('authorization');
            const [username, password] = Buffer.from(auth.replace(/^\w+\s/, ''), 'base64').toString('utf8').split(':');
            const { data: user } = await axios.post(endpoints.loginUrl, {
                username,
                password,
            });
            await updateCart(req, user.id).catch();
            helpers.setAuthenticated(req, res, user.id)
                   .status(200)
                   .send('OK');
        } catch (e) {
            res.status(401).end();
        }
    });

    app.get('/logout', (req, res) => {
        helpers.setAuthenticated(req, res, false)
            .send();
    });

    module.exports = app;
}());
