/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const axios = require("axios")
const { MockServiceAbstract } = require('./abstract');
const { MockDb } = require('../db');
const common = require('../../common');
const helpers = require('../../../helpers');
const endpoints = require('../../endpoints');

/**
 * Mocked orders service
 */
module.exports = class MockOrdersService extends MockServiceAbstract {

  constructor(router) {
    // NOTE: mocking either carts or users will force orders to mock as well
    super(router, 'orders', ...['carts', 'users']);
  }

  /**
   * setup when enabled
   */
  onEnabled() {
    this.orders = new MockDb();
  }

  /**
   * mock orders service middleware
   * @param {express.router} router
   * @return
   */
  middleware(router) {
    
    // known constants
    const ORDER = {
      SHIPPING_STANDARD: 4.99,
      TAX_RATE: 0,
    };

    // get orders for customer
    router.get('/orders', (req, res) => {
      if (!helpers.isLoggedIn(req)) {
        return next(helpers.createError("User not logged in.", 401));
      }
      const custId = helpers.getCustomerId(req);
      res.json(this.orders.find(row => custId === row.customer.id));
    })
    // get order by id
    .get('/orders/:id', (req, res) => {
      const { id } = req.params;
      res.json(this.orders.findById(id));
    })
    // create an order
    .post('/orders', async (req, res, next) => {
      
      if (!helpers.isLoggedIn(req)) {
        return next(helpers.createError("User not logged in.", 401));
      }
      
      try {
        const cartId = helpers.getCartId(req);  
        const cartItems = await common.getCartItems(cartId);
        // load customer & links
        const customer = await common.getCustomer(req);

        // resolve user address/payment card
        const [ address, card ] = await Promise.all(['addresses', 'cards']
          .map(ref => {
            // resolve each to a single result
            return axios.get(endpoints.customersUrl + '/' + customer.id + '/' + ref)
              .then(({ data }) => data)
              .then(list => list && list.length && list.pop());
          }));

        // create total
        const subtotal = cartItems
          .map(item => (item.quantity || 1) * item.unitPrice)
          .reduce((total, line) => total + line, 0);

        const tax = subtotal * ORDER.TAX_RATE;
        const shipping = subtotal ? ORDER.SHIPPING_STANDARD : 0;
        const total = subtotal + tax + shipping;

        // form final order
        const order = {
          customer,
          address,
          card,
          items: cartItems,
          orderDate: new Date().toISOString(),
          shipment: MockDb.record(),
          total,
        };
        // insert and respond
        res.json(this.orders.insert(order, true));
      } catch (e) {
        next(e);
      }
    })
  }
}