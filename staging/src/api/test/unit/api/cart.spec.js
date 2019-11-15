/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const mock = require('../../helpers/mock');
const helpers = require('../../../helpers/index');

describe('Carts', () => {
  it('should return cart items', done => {
    const id = 1;
    jest.spyOn(helpers, 'getCartId').mockReturnValue(id);

    mock.service()
      .get(`/carts/${id}/items`)
      .reply(200, [{foo: 'bar'}]);
    
    mock.app()
      .get('/api/cart')
      .expect(200)
      .expect(res => expect(res.body.length).toBeGreaterThan(0))
      .end(done);
  });

  it('should delete cart', done => {
    const id = 1;
    jest.spyOn(helpers, 'getCartId').mockReturnValue(id);

    mock.service()
      .delete(`/carts/${id}`)
      .reply(204);

    mock.app()
      .delete('/api/cart')
      .expect(204)
      .end(done);

  });

  it('should add item to cart', done => {
    const cart = 1;
    const item = { id: 12345, quantity: 2 };
    jest.spyOn(helpers, 'getCartId').mockReturnValue(cart);

    mock.service()
      .get(`/catalogue/${item.id}`)
      .reply(200, {id: item.id, price: 100})
      .post(`/carts/${cart}/items`)
      .reply(201);

    mock.app()
      .post('/api/cart')
      .send(item)
      .expect(201)
      .end(done);
  });

  it('should delete item from cart', done => {
    const cart = 1;
    const item = { id: 12345, quantity: 2 };
    jest.spyOn(helpers, 'getCartId').mockReturnValue(cart);

    mock.service()
      .delete(`/carts/${cart}/items/${item.id}`)
      .reply(204);
    
    mock.app()
      .delete(`/api/cart/${item.id}`)
      .expect(204)
      .end(done);
  });
});