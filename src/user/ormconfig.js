/**
 * TypeOrm configuration file
 * By using this file, we are able to incorporate CLI usage, and 
 * the schema synchronization into CI pipelines
 * @see https://typeorm.io/#/using-ormconfig
 */

const { OADB_SERVICE, OADB_USER, OADB_PW } = process.env;

module.exports = {
  type: 'oracle',
  username: OADB_USER,
  password: OADB_PW,
  connectString: OADB_SERVICE,
  entities: [
    '**/*.entity{.ts,.js}',
  ],
};
