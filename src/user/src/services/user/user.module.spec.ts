import * as typeorm from 'typeorm';
import { Test, TestingModule } from '@nestjs/testing';
import { UsersController } from './user.controller';
import { UserService } from './user.service';
import { ROUTE } from 'src/config/constants';
import { UserHttpModule } from './user.http.module';
import { DatabaseModule } from '../../db/database.module';
import { MockConnection } from '../../../test/helper/mock.database';
import { TypeOrmModule } from '@nestjs/typeorm';

describe('User Module', () => {
  let app: TestingModule;

  beforeEach(async () => {
    spyOn(typeorm, 'createConnection')
      .and.returnValue(Promise.resolve(new MockConnection()));

    // typeorm.createConnection()
    app = await Test.createTestingModule({
      imports: [
        DatabaseModule,
        UserHttpModule,
      ],
    }).compile();
  });

  describe(`Controller`, () => {
    let ctrl: UsersController;
    beforeEach(() => {
      ctrl = app.get<UsersController>(UsersController);
    });

    it('should be defined', () => {
      expect(ctrl).toBeDefined();
    });

  });
});
