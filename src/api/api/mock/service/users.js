const crypto = require('crypto');
const common = require('../../common');
const helpers = require('../../../helpers');

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

function userPayload(user) {
  const { salt, password, ...data } = user || {};
  return data;
}

/**
 * Mocked user service
 */
module.exports = class MockUserService extends MockServiceAbstract {

  constructor(router) {
    super(router, 'users', ...['orders']);
  }

  /**
   * setup when enabled
   */
  onEnabled() {
    // load data
    this.users = new MockDb();

    // replace method in common
    this.replaceCommon('getCustomer', 
      async req => userPayload(this.users.findById(helpers.getCustomerId(req))));
  }

  /**
   * mock user service middleware
   * @param {express.router} router 
   */
  middleware(router) {
    // registration
    router.post('/register', (req, res, next) => {
      const { password, ...meta } = req.body;
      if (!password || !meta.username || !meta.firstName || !meta.lastName) {
        return next(helpers.createError('Required fields missing', 400));
      }
      // verify no user exists with username
      if (!!this.users.first(u => meta.username === u.username)) {
        return next(helpers.createError('Unable to create user', 400));
      }
      // create user
      const salt = createSalt();
      const pass = createHash(password, salt);
      const u = this.users.insert({
        ...meta,
        salt,
        password: pass,
      });

      helpers.setAuthenticated(req, res, u.id)
        .json(userPayload(u));
    })
    .get('/login', (req, res, next) => {
      const auth = req.get('authorization');
      const [username, password] = Buffer.from(auth.replace(/^\w+\s/, ''), 'base64').toString('utf8').split(':');
      
      // find by username
      const u = this.users.first(u => username === u.username);
      if (u) {
        if (u.password === createHash(password, u.salt)) {
          return res.status(200).send('OK');
        }
      }
      return helpers.respondStatus(res, 401);
      
    })
    .get('/customers', (req, res, next) => {
      return res.json(this.users.all());
    });
  }
}