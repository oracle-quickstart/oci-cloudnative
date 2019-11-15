// tslint:disable-max-classes-per-file
import { Connection, Repository, ObjectLiteral, EntityRepository, getCustomRepository, getConnectionManager } from 'typeorm';

export function mockRepositoryFactory<T extends any>(entity: T): any {
  @EntityRepository(entity as any)
  class MockRepo extends Repository<T> {
    metadata: any = {
      columns: [],
      relations: [],
    };
  }
  return MockRepo;
}

// tslint:disable-next-line:max-classes-per-file
export class MockConnection implements Partial<Connection> {
  constructor() {
    const manager = getConnectionManager();
    spyOn(manager, 'get').and.returnValue(this);
  }

  options: any = {
    type: 'mock',
  };
  async connect() {
    return this as any;
  }

  async close() {
    return;
  }

  getRepository<T extends ObjectLiteral>(target: any): Repository<T> {
    const ctor = mockRepositoryFactory(target);
    return new ctor();
  }
}
