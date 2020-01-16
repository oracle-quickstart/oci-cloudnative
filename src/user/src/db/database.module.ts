import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

const ORM = [TypeOrmModule.forRoot()];
/**
 * ORM configurations
 */
@Module({
  imports: [...ORM],
  exports: [...ORM],
})
export class DatabaseModule { }
