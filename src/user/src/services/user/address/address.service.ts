import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { TypeOrmCrudService } from '@nestjsx/crud-typeorm';
import { Repository } from 'typeorm';

import { UserAddress } from './address.entity';

@Injectable()
export class AddressService extends TypeOrmCrudService<UserAddress> {
  constructor(@InjectRepository(UserAddress) repo: Repository<UserAddress>) {
    super(repo);
  }
}
