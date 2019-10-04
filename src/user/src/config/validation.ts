import { ValidationPipe } from '@nestjs/common';

export const validationPipes: ValidationPipe[] = [
  new ValidationPipe(),
];
