/**
 * TypeOrm configuration file
 * By using this file, we are able to incorporate CLI usage, and 
 * the schema synchronization into CI pipelines
 * @see https://typeorm.io/#/using-ormconfig
 */

// read env
const {
  OADB_ADMIN_PW,
  OADB_SERVICE,
  OADB_USER,
  OADB_PW,
  NODE_ENV,
} = process.env;

// determine opts
const admin = !!OADB_ADMIN_PW;
const prod = /^prod/i.test(NODE_ENV || '');
const useExt = prod ? 'js' : 'ts';

module.exports = {
  type: 'oracle',
  username: admin ? 'ADMIN' : OADB_USER,
  password: admin ? OADB_ADMIN_PW : OADB_PW,
  connectString: OADB_SERVICE,
  entities: [
    // use glob and prevent dupes in development when both `src` and `dist` exist
    `**/*.entity.${useExt}`,
  ],
};
