import { Module } from '@nestjs/common';
import { DatabaseModule } from './db/database.module';
import { UserHttpModule } from './services/user/user.http.module';

@Module({
  imports: [DatabaseModule, UserHttpModule],
})
export class AppModule {}
