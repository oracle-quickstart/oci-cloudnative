import { ModuleRef } from '@nestjs/core';
import { Injectable } from '@nestjs/common';
import { TypeOrmHealthIndicator } from '@nestjs/terminus';
import { promiseTimeout } from '@nestjs/terminus/dist/utils';
import { Connection } from 'typeorm';

@Injectable()
export class OracleDbHealthIndicator extends TypeOrmHealthIndicator {

  constructor(moduleRef: ModuleRef) {
    super(moduleRef);
    // override TypeOrmHealthIndicator pingDb method
    Object.assign(this, {
      pingDb: this.pingODb.bind(this),
    });
  }

  /**
   * Oracle DB "ping" query with timeout
   * @param connection
   * @param timeout
   */
  async pingODb(connection: Connection, timeout: number) {
    const check = connection.query('SELECT 1 FROM DUAL');
    return await promiseTimeout(timeout, check);
  }

}
