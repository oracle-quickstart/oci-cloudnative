/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const supertest = require('supertest');
const mock = require('../../helpers/mock');

describe('Metrics', () => {

  it('should return prom metrics', done => {
    expect.assertions(1);
    mock.app()
      .get('/metrics')
      .expect(200)
      .expect('Content-Type', /plain/)
      .expect(res => {
        expect(res.text).toContain('histogram');
      }).end(done);
  });

  it('should observe service call', done => {
    expect.assertions(1);
    mock.service()
      .get('/catalogue/foo')
      .reply(200, { bar: true });

    const agent = mock.client();
    agent
      .get('/api/catalogue/foo')
      .end(() => {
        agent
          .get('/metrics')
          .expect(res => expect(res.text).toContain('path="catalogue"'))
          .end(done);
      });
    
  });

});