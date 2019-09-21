
import { Module } from '@nestjs/common';
import { TerminusModule, TerminusModuleOptions } from '@nestjs/terminus';
import { DatabaseModule } from '../../db/database.module';
import { OracleDbHealthIndicator } from '../../db/database.health';

const getTerminusOptions = (db: OracleDbHealthIndicator ): TerminusModuleOptions => ({
  endpoints: [
    {
      url: '/health',
      healthIndicators: [
        async () => db.pingCheck('database', { timeout: 1e3 }),
      ],
    },
  ],
});

@Module({
  imports: [
    TerminusModule.forRootAsync({
      imports: [DatabaseModule],
      inject: [OracleDbHealthIndicator],
      useFactory: db => getTerminusOptions(db),
    }),
  ],
})
export class HealthModule { }
