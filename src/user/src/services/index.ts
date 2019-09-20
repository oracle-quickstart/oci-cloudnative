import { HealthModule } from './health/health.module';
import { UserHttpModule } from './user/user.http.module';

export const APP_SERVICES = [
  HealthModule,
  UserHttpModule,
];
