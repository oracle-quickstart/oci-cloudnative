const supertest = require('supertest');
const { mockService } = require('../../helpers/mock');

describe('Users', () => {
  let server;
  beforeAll(() => server = require('../../../server'));
  afterAll(() => server.close());

  describe('Auth', () => {

    it('should fail invalid login', done => {
      // mock user service login failure
      mockService()
        .get('/login')
        .reply(401);

      supertest(server)
        .get('/api/login')
        .expect(401)
        .end(done);
    });
    
    it('should do valid login', done => {
      expect.assertions(2);

      // mock the user service
      const user = { id: 12345 };
      mockService()
        .get('/login')
        .reply(200, { user });

      // call login api
      supertest(server)
        .get('/api/login')
        .auth('user', 'pass')
        .expect(res => {
          const { text, headers } = res;
          const cookie = [].concat(headers['set-cookie']).shift();
          expect(cookie).toMatch(/logged_in=[\w-]{10,}/);
          expect(text).toEqual('OK');
        }).end(done);
    });

  });


});