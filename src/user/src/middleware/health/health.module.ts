
import { Module } from '@nestjs/common';
import { TerminusModule } from '@nestjs/terminus';
import { DatabaseModule } from '../../db/database.module';
import { TerminusOptionsService } from './health.options';

@Module({
  imports: [
    TerminusModule.forRootAsync({
      imports: [DatabaseModule],
      useClass: TerminusOptionsService,
    }),
  ],
})
export class HealthModule { }
