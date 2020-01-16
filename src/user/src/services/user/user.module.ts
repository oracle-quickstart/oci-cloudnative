import { Module, Provider } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

// config
import { AppConfig } from '../../config/app';
import { MockRepository } from '../../db/mock.repository';

// User
import { User } from './user.entity';
import { UserService } from './user.service';

// User Addresses
import { UserAddress } from './address/address.entity';
import { AddressService } from './address/address.service';

// User Credit Cards
import { UserCard } from './card/card.entity';
import { CardService } from './card/card.service';

// Provide extra features for MockDb mode
const features: any[] = [User, UserAddress, UserCard];
const featureProviders: Provider[] = features
  .map(f => AppConfig.common().mockDb() && MockRepository.forEntity(f))
  .filter(p => !!p);

/**
 * User Module with ORM services
 */
@Module({
  imports: [TypeOrmModule.forFeature(features)],
  providers: [...featureProviders, UserService, AddressService, CardService],
  exports: [UserService, AddressService, CardService],
})
export class UserModule { }
