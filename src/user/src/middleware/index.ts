import { MetricsModule } from './metrics/metrics.module';
import { HealthModule } from './health/health.module';

export const APP_MIDDLEWARE = [
  MetricsModule,
  HealthModule,
];
