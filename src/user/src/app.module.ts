import { Module, NestModule, MiddlewareConsumer } from '@nestjs/common';
import { APP_MIDDLEWARE } from './middleware';
import { APP_SERVICES } from './services';

@Module({
  imports: [
    ...APP_MIDDLEWARE,
    ...APP_SERVICES,
  ],
})
export class AppModule {}
