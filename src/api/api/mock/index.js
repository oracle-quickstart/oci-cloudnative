const axios = require("axios");
const express = require("express");
const helpers = require("../../helpers");
const config = require('../../config');
const endpoints = require('../endpoints');
const { MockDb } = require('./db');



/**
 * MuShop "offline" mock middleware
 */
class MockMiddleware {
  constructor() {
    this._router = express.Router();
    // create mock handlers when is mock mode
    this._mock = config.mockMode() && this._init();
  }

  _init() {
    // mock services accessed directly
    console.log('API services using MOCK mode');
    return this._mockCatalog()
      ._mockCart()
      ._mockOrders();
  }

  /**
   * mock catalogue handlers
   */
  _mockCatalog() {
    const app = this.layer();
    const products = this.products = new MockDb(require('./data/mock_products.json'));
    const cats = this.categories = new MockDb(require('./data/mock_categories.json'));
    // categories
    app.get('/categories', (req, res) => res.json(cats.all()));

    // catalogue products
    app.get('/catalogue', (req, res) => {
      const { size, offset } = req.query;
      res.json(products.find(null, size, offset));
    }).get('/catalogue/:sku', (req, res) => {
      const { sku } = req.params;
      res.json(products.findById(sku));
    });
    
    return this;
  }

  /**
   * mock the cart service
   */
  _mockCart() {
    const app = this.layer();
    const carts = this.carts = new MockDb();

    /**
     * helper function to get the mock cart from request object
     * @param {express.Request} req 
     */
    function getCart(req) {
      // id must be preserved from session
      const id = helpers.getCartId(req);
      return carts.findById(id) || MockDb.record({
        id,
        items: new MockDb(),
      });
    }

    // MIDDLEWARE

    // get the cart
    app.get('/cart', (req, res) => { 
      const { id, items } = getCart(req);
      return res.json(items.all());
    })
    // add a cart item
    .post('/cart', (req, res) => {
      const { id, quantity } = req.body;
      const { id: cartId, items } = getCart(req);
      const product = this.products.findById(id);
      const item = items.first(row => id === row.itemId) || MockDb.record();
      items.upsert(item.id, {
        ...item,
        itemId: id,
        quantity: (item.quantity || 0) + (~~quantity || 1),
        unitPrice: product.price,
      });
      carts.upsert(cartId, { items });
      helpers.respondStatus(res, 201);
    })
    // update a cart item
    .post('/cart/update', (req, res, next) => {
      const { id, quantity } = req.body;
      const { id: cartId, items } = getCart(req);
      const product = this.products.findById(id);
      const item = items.first(row => id === row.itemId) || MockDb.record();
      items.upsert(item.id, {
        ...item,
        itemId: id,
        quantity: ~~quantity,
        unitPrice: product.price,
      });
      carts.upsert(cartId, { items });
      helpers.respondStatus(res, 202);
    })
    // delete the cart
    .delete('/cart', (req, res) => {
      const { id } = getCart(req);
      carts.delete(r => id === r.id);
      helpers.respondStatus(res, 202);
    })
    // remove a cart item
    .delete('/cart/:sku', (req, res) => {
      const { items } = getCart(req);
      const { sku } = req.params;
      items.delete(row => sku === row.itemId);
      helpers.respondStatus(res, 202);
    });

    return this;
  }

  /**
   * mock the orders service
   */
  _mockOrders() {
    const app = this.layer();
    const orders = this.orders = new MockDb();

    const ORDER = {
      SHIPPING_STANDARD: 4.99,
      TAX_RATE: 0,
    };

    // get orders for customer
    app.get('/orders', (req, res) => {
      if (!helpers.isLoggedIn(req)) {
        return next(helpers.createError("User not logged in.", 401));
      }
      const custId = helpers.getCustomerId(req, app.get('env'));
      res.json(orders.find(row => custId === row.customer.id));
    })
    // get order by id
    .get('/orders/:id', (req, res) => {
      const { id } = req.params;
      res.json(orders.findById(id));
    })
    // create an order
    .post('/orders', async (req, res, next) => {
      
      if (!helpers.isLoggedIn(req)) {
        return next(helpers.createError("User not logged in.", 401));
      }
      const customerId = helpers.getCustomerId(req, app.get('env'));
      const cart = this.carts.findById(helpers.getCartId(req));
      try {
        // load customer & links (NOT MOCKED)
        const { data: customer } = await axios.get(endpoints.customersUrl + "/" + customerId);
        const { _links: { addresses, cards }} = customer;

        // resolve user address/payment card
        const [ address, card ] = await Promise.all([
          { link: addresses, key: 'address' },
          { link: cards, key: 'card' },
        ].map(ref => {
          // resolve each to a single result
          return axios.get(ref.link.href)
            .then(({ data }) => data._embedded && data._embedded[ref.key])
            .then(list => list && list.length && list.pop());
        }));

        // create total
        const subtotal = cart.items.all()
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
          items: cart.items.all(),
          orderDate: new Date().toISOString(),
          shipment: MockDb.record(),
          total,
        };
        // insert and respond
        res.json(orders.insert(order, true));
      } catch (e) {
        next(e);
      }
    })
    return this;
  }
  
  layer() {
    return this._router;
  }
}

module.exports = new MockMiddleware();