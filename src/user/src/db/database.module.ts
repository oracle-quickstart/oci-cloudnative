import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OracleDbHealthIndicator } from './database.health';

const ORM = [TypeOrmModule.forRoot()];

/**
 * ORM configurations
 */
@Module({
  imports: [...ORM],
  exports: [OracleDbHealthIndicator, ...ORM],
  providers: [OracleDbHealthIndicator],
})
export class DatabaseModule {}
