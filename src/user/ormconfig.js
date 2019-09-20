/**
 * TypeOrm configuration file
 * By using this file, we are able to incorporate CLI usage, and 
 * the schema synchronization into CI pipelines
 * @see https://typeorm.io/#/using-ormconfig
 */

// read env
const { OADB_SERVICE, OADB_USER, OADB_PW, NODE_ENV } = process.env;

// determine opts
const prod = /^prod/i.test(NODE_ENV || '');
const useExt = prod ? 'js' : 'ts';

module.exports = {
  type: 'oracle',
  username: OADB_USER,
  password: OADB_PW,
  connectString: OADB_SERVICE,
  entities: [
    `**/*.entity.${useExt}`,
  ],
};
