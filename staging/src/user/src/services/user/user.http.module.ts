import { Module, MiddlewareConsumer, NestModule } from '@nestjs/common';
import { LoggerMiddleware } from '../../middleware/logger/logger.middleware';

import { AuthModule } from '../../auth/auth.module';
import { UserModule } from './user.module';
import { UsersController } from './user.controller';

// relational /customers/:userId/{resource}
import { UserCardsController } from './user.cards.controller';
import { UserAddressController } from './user.address.controller';

// standalone
import { AddressController } from './address/address.controller';
import { CardsController } from './card/card.controller';

/**
 * User Module with CRUD controllers
 */
@Module({
  imports: [AuthModule, UserModule],
  controllers: [
    UsersController,        /* /customers */
    UserCardsController,    /* /customers/:id/cards */
    UserAddressController,  /* /customers/:id/addresses */
    AddressController,      /* /addresses */
    CardsController,        /* /cards */
  ],
})
export class UserHttpModule implements NestModule {

  configure(consumer: MiddlewareConsumer): any {
    consumer
      .apply(LoggerMiddleware())
      .forRoutes('*');
  }

}
