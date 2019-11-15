import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

// User
import { User } from './user.entity';
import { UserService } from './user.service';

// User Addresses
import { UserAddress } from './address/address.entity';
import { AddressService } from './address/address.service';

// User Credit Cards
import { UserCard } from './card/card.entity';
import { CardService } from './card/card.service';

/**
 * User Module with ORM services
 */
@Module({
  imports: [TypeOrmModule.forFeature([User, UserAddress, UserCard])],
  exports: [UserService, AddressService, CardService],
  providers: [UserService, AddressService, CardService],
})
export class UserModule { }
