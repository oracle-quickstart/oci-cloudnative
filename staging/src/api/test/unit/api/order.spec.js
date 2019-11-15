/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const mock = require('../../helpers/mock');
const helpers  =require('../../../helpers/index');

describe('Orders', () => {

  it('should fail when not logged in', done => {
    expect.assertions(1);
    mock.app()
      .get('/api/orders')
      .expect(401)
      .end((err, res) => {
        expect(res.body.error).toBeDefined();
        done();
      });
  });

  it('should list orders', done => {
    expect.assertions(1);
    mock.service()
      .get(/orders\/search/)
      .reply(200, {
        _embedded: {
          customerOrders: [{ id: 1, orderDate: new Date().toISOString() }]
        }
      });

    const spy = jest.spyOn(helpers, 'getCustomerId').mockReturnValue('765adf');
    mock.app()
      .get('/api/orders')
      .set('Cookie', ['logged_in=true'])
      .expect(200)
      .expect(res => expect(res.body.length).toBe(1))
      .end(done);

  });

  it('should return empty orders list if none found', done => {
    expect.assertions(1);
    mock.service()
      .get(/orders\/search/)
      .reply(404);

    const spy = jest.spyOn(helpers, 'getCustomerId').mockReturnValue('765adf');
    mock.app()
      .get('/api/orders')
      .set('Cookie', ['logged_in=true'])
      .expect(200)
      .expect(res => expect(res.body.length).toBe(0))
      .end(done);
  });

  it('should return a single order id', done => {
    const orderId = 123;
    mock.service()
      .get(`/orders/${orderId}`)
      .reply(200, { orderId });

    mock.app()
      .get(`/api/orders/${orderId}`)
      .expect(200)
      .end(done);
  });

});