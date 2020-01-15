/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
(function () {
    'use strict';

    const axios = require("axios")
        , express = require("express")
        , helpers = require("../../helpers")
        , endpoints = require("../endpoints")
        , app = express.Router()

    // Subscribe the email address to the newsletter
    app.post('/newsletter', async (req, res, next) => {
        const { email } = req.body;
        if (!email) {
            return next(helpers.createError('Email was not provided', 400));
        }

        if (!endpoints.newsletterSubscribeUrl) {
            // Since we don't require the URL to be set, just respond with a mock 200.
            helpers.respondSuccessBody(res, {'messageId': 'mock-message-id'});
            return;
        }

        try {
            // Invoke the newsletter-subscribe function through the API Gateway
            const { status } = await axios.post(endpoints.newsletterSubscribeUrl, { email });
            if (status !== 200) {
                return next(helpers.createError(`Unable to sign up for newsletter. Status code: ${status}`), status)
            }
            helpers.respondStatus(res, status);
        } catch (e) {
            next(e);
        }
    });

    module.exports = app;
}());
