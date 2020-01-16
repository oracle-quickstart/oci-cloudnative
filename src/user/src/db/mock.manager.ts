
// tslint:disable max-classes-per-file
import { Injectable, Logger } from '@nestjs/common';
import { ObjectType, ObjectLiteral, EntityManager, SelectQueryBuilder } from 'typeorm';
import { MockQueryBuilder } from './mock.querybuilder';
import uuid = require('uuid/v4');

type DTO = ObjectLiteral & {
  id: string;
};

type FilterCb<T> = (row: T) => boolean;

export function toEqFilter<T extends DTO>(where: Partial<T>): FilterCb<T> {
  return (row: T) =>
    Object.keys(where).reduce((test, key) => test && where[key] === row[key], true);
}

export function pick<T extends DTO, K extends keyof T>(picks: K[], row: T): Pick<T, K> {
  if (row && picks) {
    return Object.assign({}, ...picks.map(key => ({[key]: row[key]})));
  }
  return row;
}

// tslint:disable-next-line:no-empty-interface
export interface MockEntityManager extends EntityManager { }

@Injectable()
export class MockEntityManager implements Partial<EntityManager> {

  private static instance = new MockEntityManager();
  public static manager(): MockEntityManager {
    return this.instance;
  }
  public static manage(target: ObjectType<DTO>, alias: string) {
    const { stores, aliases } = this.instance;
    if (!stores.has(target)) {
      stores.set(target, new MockDb(alias));
      aliases.set(alias, target);
    }
    return this.instance;
  }

  private aliases = new Map<string, ObjectType<DTO>>();
  private stores = new Map<any, MockDb<any>>();
  private logger = new Logger(this.constructor.name);
  private getStore(target: any): MockDb<any> {
    return this.stores.get(this.aliases.get(target) || target);
  }

  /**
   * Intercept querybuilder used by Crud
   * @param target
   * @param alias
   */
  createQueryBuilder<T extends ObjectType<DTO>= any>(target: T, alias?: string): SelectQueryBuilder<any> {
    return MockQueryBuilder.create(target, alias, this as EntityManager);
  }

  async save<T extends ObjectType<DTO>= any>(target: T, entities: any): Promise<any> {
    const db = this.getStore(target);
    const results = [].concat(entities)
      .map((r: DTO) => db.upsert(db.create(r)));
    this.logger.debug(`Saved ${results.length}`);
    return Array.isArray(entities) ? results : results.shift();
  }

  async remove<T extends ObjectType<DTO>= any>(target: T, entities: any): Promise<any> {
    const db = this.getStore(target);
    const ids = [].concat(entities)
      .map((row: DTO) => row.id);
    return db.delete((row: DTO) => ids.includes(row.id));
  }

  async find<T extends ObjectType<DTO>= any>(target: T, conditions: any): Promise<T[]> {
    const { where = {}, limit = 0, offset = 0, fields } = conditions;
    const db = this.getStore(target);
    return db.find(toEqFilter(where), limit, offset)
      .map(pick.bind(null, fields));
  }

  async findOne<T extends DTO, K extends ObjectType<T>= any>(target: K, conditions?: any): Promise<Partial<T>> {
    this.logger.debug('FIND ONE');
    const db = this.getStore(target);
    if (typeof conditions === 'string') {
      return db.findById(conditions);
    } else if (typeof conditions === 'object') {
      const { where = {}, fields } = conditions;
      this.logger.debug(where);
      const result = db.first(toEqFilter(where as Partial<T>));
      return pick<T, keyof T>(fields, result);
    }
  }

}

/**
 * In-memory database
 */
export class MockDb<T extends DTO> {
  private logger = new Logger(this.constructor.name);
  private collection: T[] = [];
  constructor(public alias: string) {
    this.logger.warn(`Using memory datasource for ${alias}, this does not scale`);
  }

  create(data: Partial<T> = {}): T {
    return {
      id: uuid(),
      ...data,
    } as T;
  }

  all() {
    return this.collection;
  }

  first(filter?: FilterCb<T>) {
    return this.collection.find(filter || (() => true));
  }

  last(filter?: FilterCb<T>) {
    return [].concat(this.collection).reverse().find(filter || (() => true));
  }

  find(filter?: FilterCb<T>, limit?: number, offset?: number) {
    return this.collection
      .filter(filter || (() => true))
      .slice(offset, offset ? offset + limit : limit);
  }

  findById(id: string) {
    return this.first(row => id === row.id);
  }

  delete(filter?: FilterCb<T>) {
    this.collection = this.collection.filter(row => filter && !filter(row));
  }

  insert(data?: Partial<T>, prepend?: boolean) {
    const row = this.create(data);
    this.collection[prepend ? 'unshift' : 'push'](row);
    return row;
  }

  upsert(data: T): T;
  upsert(id: string | T, data?: T): T {
    if (!data) {
      data = id as T;
      id = data.id;
    }
    const prev = this.findById(id as string);
    if (!prev) {
      return this.insert({id, ...data});
    } else {
      return Object.assign(prev, data);
    }
  }
}
