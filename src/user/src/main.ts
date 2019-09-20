import './config/crud';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { validationPipes } from './config/validation';

// Allow specific port when multiple services running on box
const { PORT_USERS, PORT } = process.env;
const port = PORT_USERS || PORT || 3000;

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.useGlobalPipes(...validationPipes);
  await app.listen(port);
}
bootstrap();
