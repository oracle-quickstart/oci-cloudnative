import { Injectable } from '@nestjs/common';
import { TerminusEndpoint, TerminusOptionsFactory, TypeOrmHealthIndicator, TerminusModuleOptions } from '@nestjs/terminus';
import { AppConfig } from '../../config/app';

@Injectable()
export class TerminusOptionsService implements TerminusOptionsFactory {
  private conf = AppConfig.common();
  constructor(private orm: TypeOrmHealthIndicator) { }

  createTerminusOptions(): TerminusModuleOptions {
    // create the endpoint config
    const [HEALTH_DB] = ['database'];
    const healthEndpoint: TerminusEndpoint = {
      url: '/health',
      healthIndicators: [
        async () => this.conf.mockDb() ?
          ({ [HEALTH_DB]: { status: 'ok' } }) :
          this.orm.pingCheck(HEALTH_DB, { timeout: 2e3 }),
      ],
    };
    // return options
    return {
      endpoints: [healthEndpoint],
    };
  }
}
