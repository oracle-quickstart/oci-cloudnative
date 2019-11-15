import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { TypeOrmCrudService } from '@nestjsx/crud-typeorm';
import { Repository } from 'typeorm';

import { UserCard } from './card.entity';

@Injectable()
export class CardService extends TypeOrmCrudService<UserCard> {
  constructor(@InjectRepository(UserCard) repo: Repository<UserCard>) {
    super(repo);
  }
}
