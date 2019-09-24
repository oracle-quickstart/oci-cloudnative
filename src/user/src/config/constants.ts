// tslint:disable-next-line:no-var-requires
const PKG: any = require('../../package.json');

export const APP = {
  NAME: 'user',
  VERSION: PKG.version,
};

export enum ROUTE {
  USERS = 'customers',
  CARDS = 'cards',
  ADDRESSES = 'addresses',
  LOGIN = 'login',
  REGISTER = 'register',
}
