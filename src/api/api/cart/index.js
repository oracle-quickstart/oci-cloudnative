/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
(function (){
  'use strict';

  const axios = require("axios")
    , express   = require("express")
    , helpers   = require("../../helpers")
    , endpoints = require("../endpoints")
    , common = require("../common")
    , app       = express.Router()

  // List items in cart for current logged in user.
  app.get("/cart", function (req, res, next) {
    const cartId = helpers.getCartId(req);

    common.getCartItems(cartId)
      .then(data => res.json(data))
      .catch(next);
  });

  // Delete cart
  app.delete("/cart", function (req, res, next) {
    const cartId = helpers.getCartId(req);

    axios.delete(endpoints.cartsUrl + "/" + cartId)
      .then(({ status }) => helpers.respondStatus(res, status))
      .catch(next);
  });

  // Delete item from cart
  app.delete("/cart/:id", function (req, res, next) {
    const cartId = helpers.getCartId(req);
    const { id } = req.params;

    axios.delete(endpoints.cartsUrl + "/" + cartId + "/items/" + id)
      .then(({ status }) => helpers.respondStatus(res, status))
      .catch(next);
  });

  // Add new item to cart
  app.post("/cart", async function (req, res, next) {
    const cartId = helpers.getCartId(req);
    const item = req.body;

    if (!item.id) {
      return next(helpers.createError("Must pass id of item to add", 400));
    }
    try {
      // lookup product information
      const product = await common.getProduct(item.id);
      // post to cart items with default quantity

      const { status } = await axios.post(endpoints.cartsUrl + "/" + cartId, {
        customerId: helpers.isLoggedIn(req) ? req.session.customerId : null,
        items: [{
          itemId: product.id,
          unitPrice: product.price,
        }]
      });
      // verify created
      if (status !== 201 && status != 200) {
        return next(helpers.createError("Unable to add to cart. Status code: " + status, status));
      }
      helpers.respondStatus(res, status);
    } catch (e) {
      next(e);
    }
  });

  // Update cart item
  app.post("/cart/update", async function (req, res, next) {
    const cartId = helpers.getCartId(req);
    const item = req.body;

    if (!item.id) {
      return next(helpers.createError("Must pass id of item to update", 400));
    }

    if (!item.quantity) {
      return next(helpers.createError("Must pass quantity to update", 400));
    }

    try {
      // lookup product information
      const product = await common.getProduct(item.id);
      // patch cart
      const { status } = await axios.patch(endpoints.cartsUrl + "/" + cartId + "/items", {
        itemId: product.id,
        unitPrice: product.price,
        quantity: ~~item.quantity,
      });

      // verify accepted
      if (status !== 202) {
        return next(helpers.createError("Unable to update cart. Status code: " + status, status));
      }
      helpers.respondStatus(res, status);
    } catch (e) {
      next(e);
    }

  });

  module.exports = app;
}());
