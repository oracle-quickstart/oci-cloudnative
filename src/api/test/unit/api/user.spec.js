/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const mock = require('../../helpers/mock');
const helpers  =require('../../../helpers/index');

describe('Users', () => {

  describe('Auth', () => {
    let agent;
    beforeAll(() => agent = mock.client());

    it('should fail invalid login', done => {
      // mock user service login failure
      mock.service()
        .get('/login')
        .reply(401);

      agent
        .get('/api/login')
        .auth('user', 'pass')
        .expect(401)
        .end(done);
    });
    
    it('should do valid login', done => {
      expect.assertions(2);

      // mock the user service
      const user = { id: 12345 };
      mock.service()
        .get('/login')
        .reply(200, { user });

      // call login api
      agent
        .get('/api/login')
        .auth('user', 'pass')
        .expect(res => {
          const { text, headers } = res;
          const cookie = [].concat(headers['set-cookie']).shift();
          expect(cookie).toMatch(/logged_in=[\w-]{10,}/);
          expect(text).toEqual('OK');
        }).end(done);
    });

    it('should do logout', done => {
      agent
        .get('/api/logout')
        .expect(200)
        .expect(res => {
          const { headers } = res;
          const cookie = [].concat(headers['set-cookie']).shift();
          expect(cookie).toContain('logged_in=;');
        }).end(done);
    });

  });

  describe('Profile', () => {

    it('should return a profile', done => {
      expect.assertions(2);
      const id = `abcde12345`
      const spy = jest.spyOn(helpers, 'getCustomerId').mockReturnValue(id);
      
      mock.service()
        .get(`/customers/${id}`)
        .reply(200, { id, firstName: 'Tester' });

      mock.app()
        .get('/api/profile')
        .expect(res => {
          expect(spy).toHaveBeenCalledTimes(1);
          expect(res.body.id).toEqual(id);
        }).end(done);

    });

    it('should register', done => {
      expect.assertions(2);

      mock.service()
        .post('/register')
        .reply(200, { id: 1234 })

      mock.app()
        .post('/api/register')
        .send({ firstName: 'foo', lastName: 'bar' })
        .expect('Content-Type', /json/)
        .expect(res => {
          const { body, headers } = res;
          const cookie = [].concat(headers['set-cookie']).shift();
          expect(cookie).toMatch(/logged_in=[\w-]{10,}/);
          expect(body.id).toBeDefined();
        }).end(done);
      
    });

    it('should allow customer endpoint', done => {
      expect.assertions(1);
      const u = { id: 7654567, name: 'Tester' };
      jest.spyOn(helpers, 'getCustomerId').mockReturnValue(u.id);

      mock.service()
        .get(`/customers/${u.id}`).reply(200, u);
      
      mock.app()
        .get(`/api/customers/${u.id}`)
        .expect(200)
        .expect(res => expect(res.body.id).toEqual(u.id))
        .end(done);
    });

    it('should deny non-authenticated customer profile', done => {
      jest.spyOn(helpers, 'getCustomerId').mockReturnValue(1);
      mock.app()
        .get(`/customers/2`)
        .expect(401)
        .end(done);
    });

  });

  describe('WAF Demo', () => {
    const tests = ['addresses', 'cards', 'customers'];
    tests.forEach(ep => {
      it(`should return mock ${ep} for demo`, done => {
        expect.assertions(2);
        mock.app()
          .get(`/${ep}`)
          .expect(200)
          .expect(({ body }) => {
            expect(body.mock).toBe(true);
            expect(body._embedded).toBeDefined();
          }).end(done);
      });
    });
  });

});