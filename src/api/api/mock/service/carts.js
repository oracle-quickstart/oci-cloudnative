/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const { MockServiceAbstract } = require('./abstract');
const { MockDb } = require('../db');
const common = require('../../common');
const helpers = require('../../../helpers');

/**
 * Mocked carts service
 */
module.exports = class MockCartsService extends MockServiceAbstract {

  constructor(router) {
    super(router, 'carts');
  }

  /**
   * setup when enabled
   */
  onEnabled() {
    this.carts = new MockDb();

    // replace method in common
    this.replaceCommon('getCartItems', async id => this.getCart(id).items.all());
  }

  /**
   * mock carts service middleware
   * @param {express.router} router 
   */
  middleware(router) {
    // get the cart
    router.get('/cart', async (req, res) => {
      const { items } = this.getCartForReq(req);
      return res.json(items.all());
    })
    // add a cart item
    .post('/cart', async (req, res, next) => {
      const { id, quantity } = req.body;
      const { id: cartId, items } = this.getCartForReq(req);
      try {
        const product = await common.getProduct(id);
        const item = items.first(row => id === row.itemId) || MockDb.record();
        items.upsert(item.id, {
          ...item,
          itemId: id,
          quantity: (item.quantity || 0) + (~~quantity || 1),
          unitPrice: product.price,
        });
        this.carts.upsert(cartId, { items });
        helpers.respondStatus(res, 201);
      } catch(e) {
        next(e);
      }
    })
    // update a cart item
    .post('/cart/update', async (req, res, next) => {
      const { id, quantity } = req.body;
      const { id: cartId, items } = this.getCartForReq(req);
      try {
        const product = await common.getProduct(id);
        const item = items.first(row => id === row.itemId) || MockDb.record();
        items.upsert(item.id, {
          ...item,
          itemId: id,
          quantity: ~~quantity,
          unitPrice: product.price,
        });
        this.carts.upsert(cartId, { items });
        helpers.respondStatus(res, 202);
      } catch(e) {
        next(e);
      }
    })
    // delete the cart
    .delete('/cart', (req, res) => {
      const { id } = this.getCartForReq(req);
      this.carts.delete(r => id === r.id);
      helpers.respondStatus(res, 202);
    })
    // remove a cart item
    .delete('/cart/:sku', (req, res) => {
      const { items } = this.getCartForReq(req);
      const { sku } = req.params;
      items.delete(row => sku === row.itemId);
      helpers.respondStatus(res, 202);
    });
  }

  /**
   * get cart by id
   * @param {string} id 
   */
  getCart(id) {
    return this.carts.findById(id) || MockDb.record({
      id,
      items: new MockDb(),
    });
  }

  /**
   * get cart by request
   * @param {express.Request} req 
   */
  getCartForReq(req) {
    const id = helpers.getCartId(req);
    return this.getCart(id);
  }
}
