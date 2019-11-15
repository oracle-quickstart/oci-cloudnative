/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const { MockDb } = require('../../../api/mock/db');

describe('MockDb', () => {

    it('should create a record', () => {
      const row = MockDb.record({ foo: 'bar' });
      expect(row.foo).toEqual('bar');
      expect(row.id).toBeDefined();
    });

    it('should create a record with no data', () => {
      const row = MockDb.record();
      expect(row.id).toBeDefined();
    });

    it('should create a memory db', () => {
      // create db
      const db = new MockDb();
      expect(db.all()).toBeTruthy();
      // insert rows
      Array.apply(null, Array(10)).forEach((x, i) => db.insert(MockDb.record({ i })));
      // prepend a row
      db.insert(MockDb.record({name: 'foo'}), true);
      expect(db.all().length).toBe(11);
      // find a row
      expect(db.first(r => !!r)).toBeTruthy();
      expect(db.first()).toBeTruthy();
      // find results
      expect(db.find(null, 2, 2).length).toBe(2);
      expect(db.find(null, 2).length).toBe(2);

      // lookup and upsert
      const row = db.insert({name: 'bar'});
      expect(db.upsert(row.id, row)).toBeTruthy();

      // delete
      const len = db.all().length;
      db.delete(r => r.id === row.id);
      expect(len).not.toEqual(db.all().length);
    });
});