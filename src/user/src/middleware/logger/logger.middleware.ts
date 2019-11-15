import * as morgan from 'morgan';
import { RequestHandler } from 'express';
import { AppConfig } from '../../config/app';

export function LoggerMiddleware(): RequestHandler {
  return morgan(AppConfig.common().prod() ? 'combined' : 'dev');
}
