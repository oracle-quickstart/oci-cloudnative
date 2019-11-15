/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const crypto = require('crypto');
const helpers = require('../../../helpers');
const config = require('../../../config');
const endpoints = require('../../endpoints');

const { MockServiceAbstract } = require('./abstract');
const { MockDb } = require('../db');

function createSalt(length = 16) {
  return crypto.randomBytes(Math.ceil(length/2))
    .toString('hex')
    .slice(0,length);
}

function createHash(string, salt) {
  const hmac = crypto.createHmac('sha512', salt);
  hmac.update(string);
  return hmac.digest('hex');
}

function userRecord(user) {
  const { password, ...data } = user;
  const salt = createSalt();
  return MockDb.record({
    salt,
    password: createHash(password, salt),
    addresses: new MockDb(),
    cards: new MockDb(),
    ...data,
  });
}

function userResponse(user) {
  const { salt, password, addresses, cards, ...data } = user;
  return  { ...data };
}

/**
 * Mocked user service
 */
module.exports = class MockUserService extends MockServiceAbstract {

  constructor(router) {
    super(router, 'users', ...['orders']);
  }

  /**
   * get current user from db
   * @param {express.Request} req 
   */
  _user(req) {
    return this.users.findById(helpers.getCustomerId(req));
  }

  /**
   * setup when enabled
   */
  onEnabled() {
    // create db
    this.users = new MockDb();

    // replace method in common
    this.replaceCommon('getCustomer', 
      async req => userResponse(this._user(req)));
    // replace users target endpoint
    endpoints.customersUrl = MockServiceAbstract.link('/customers');

    // seed db
    if (!config.prod()) {
      const dummy = this.users.insert(userRecord({
        username: 'user',
        password: 'password',
        firstName: 'Test',
        lastName: 'User',
      }));
      dummy.addresses.insert({
        number: 1234,
        street: 'Meep St',
        city: 'Meepville',
        country: 'USA',
        postcode: '00000', 
      });
      dummy.cards.insert({
        number: '5678',
        longNum: 'xxxx5678',
        expires: '12/99',
      });
    }
  }

  /**
   * mock user service middleware
   * @param {express.router} router 
   */
  middleware(router) {
    // registration
    router.post('/register', (req, res, next) => {
      const meta = req.body;
      // validate
      if (['password', 'username', 'firstName', 'lastName'].some(f => !meta[f])) {
        return next(helpers.createError('Required fields missing', 400));
      }
      // verify no user exists with username
      if (!!this.users.first(u => meta.username === u.username)) {
        return next(helpers.createError('Unable to create user', 400));
      }
      // create user record
      const u = this.users.insert(userRecord(meta));

      helpers.setAuthenticated(req, res, u.id)
        .json(userResponse(u));
    })
    
    // authentication
    .post('/login', (req, res) => {
      const auth = req.get('authorization');
      const [username, password] = Buffer.from(auth.replace(/^\w+\s/, ''), 'base64').toString('utf8').split(':');

      // validate username/password match
      const u = this.users.first(u => username === u.username);
      if (u && u.password === createHash(password, u.salt)) {
        return helpers.setAuthenticated(req, res, u.id)
            .status(200)
            .send('OK');
      }
      return helpers.respondStatus(res, 401);
    });

    // customer address
    router.get('/address', (req, res) => {
      const address = this._user(req).addresses.last();
      return address ? res.json(address) : helpers.respondStatus(res, 404);
    })
    .post('/address', (req, res) => {
      const addr = this._user(req).addresses.insert(req.body);
      return res.json(addr);
    })
    .delete('/addresses/:id', (req, res) => {
      this._user(req).addresses.delete(a => a.id === req.params.id);
      helpers.respondStatus(res, 200);
    });

    // customer cards
    router.get('/card', (req, res) => {
      const card = this._user(req).cards.last();
      return card ? res.json(card) : helpers.respondStatus(res, 404);
    })
    .post('/card', (req, res) => {
      const { longNum, expires } = req.body;
      const card = this._user(req).cards.insert({
        expires,
        longNum: Array.apply(null, Array(12)).join('x') + longNum.slice(-4),
        number: longNum.slice(-4),
      });
      res.json(card);
    })
    .delete('/cards/:id', (req, res) => {
      this._user(req).cards.delete(c => c.id === req.params.id);
      helpers.respondStatus(res, 200);
    });

    // Endpoints called by related services (orders)
    const links = ['addresses', 'cards'];
    links.forEach(ref => {
      router.get(`/customers/:id/${ref}`, (req, res) => {
        const { id } = req.params;
        const u = this.users.findById(id);
        res.json(u[ref].all());
      });
    });
  }

}
