
// tslint:disable-max-classes-per-file
import { Provider } from '@nestjs/common';
import { getRepositoryToken, getEntityManagerToken } from '@nestjs/typeorm';
import { Repository, EntityRepository, ObjectLiteral, EntityManager, getCustomRepository } from 'typeorm';
import { MockEntityManager } from './mock.manager';

/**
 * Creates a mock repository for a TypeORM entity
 */
export class MockRepository extends Repository<any> {

  public static forEntity<T extends ObjectLiteral>(entity: T): Provider {
    return {
      provide: getRepositoryToken(entity as any),
      inject: [getEntityManagerToken()],
      useFactory: async (manager: EntityManager) => this.factory(manager, entity),
    };
  }

  private static factory<T extends ObjectLiteral>(manager: EntityManager, entity: T) {
    // tslint:disable-next-line:max-classes-per-file
    @EntityRepository(entity as any)
    class EntityRepo extends MockRepository { }
    return getCustomRepository(EntityRepo);
  }

  /**
   * overload the readonly Repository.manager property
   */
  public set manager(m: MockEntityManager) { /* */ }
  public get manager(): MockEntityManager {
    return MockEntityManager.manage(this.metadata.target as any, this.metadata.name);
  }

}
