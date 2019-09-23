/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const ulid = require("ulid");

/**
 * Basic Mock Store
 * @note This is for development, and does not scale
 */
class MockDb {

  /**
   * create a mock record
   * @param {*} data 
   */
  static record(data = {}) {
    return {
      id: ulid.ulid(),
      ...data,
    };
  }

  constructor(data) {
    this._col = data || [];
  }

  all() {
    return this._col;
  }

  first(filter) {
    return this._col.find(filter || (() => true));
  }

  last(filter) {
    return [].concat(this._col).reverse().find(filter || (() => true));
  }

  find(filter, limit, offset) {
    return this._col
      .filter(filter || (() => true))
      .slice(offset, offset ? offset + limit : limit);
  }

  findById(id) {
    return this.first(row => id === row.id);
  }

  delete(filter) {
    this._col = this._col.filter(row => filter && !filter(row));
  }

  insert(data, prepend) {
    const row = MockDb.record(data);
    this._col[prepend ? 'unshift' : 'push'](row);
    return row;
  }

  upsert(id, data) {
    const prev = this.findById(id);
    if (!prev) {
      return this.insert({id, ...data});
    } else {
      return Object.assign(prev, data);
    }
  }
}

module.exports = {
  MockDb,
};
