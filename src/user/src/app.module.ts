import { Module } from '@nestjs/common';
import { APP_SERVICES } from './services';

@Module({
  imports: [...APP_SERVICES],
})
export class AppModule {}
