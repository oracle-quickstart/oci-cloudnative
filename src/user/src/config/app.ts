
export interface IAppEnv {
  OADB_SERVICE: string;
  OADB_USER: string;
  OADB_PW: string;
  NODE_ENV?: string;
}

export type IDBConfig = Pick<IAppEnv, 'OADB_SERVICE' | 'OADB_USER' | 'OADB_PW'>;

export class AppConfig {
  private static COMMON: AppConfig = new AppConfig();
  public static common(c?: AppConfig): AppConfig {
    this.COMMON = c || this.COMMON;
    return this.COMMON;
  }

  constructor(private ENV: IAppEnv = process.env as any) {

  }

  public env(): IAppEnv {
    return {...this.ENV};
  }

  public prod(): boolean {
    const { NODE_ENV } = this.ENV;
    return /^prod/i.test(NODE_ENV || '');
  }

  /**
   * get db configuration
   */
  public dbConfig(): IDBConfig {
    const { OADB_SERVICE, OADB_USER, OADB_PW } = this.ENV;
    return {
      OADB_SERVICE,
      OADB_USER,
      OADB_PW,
    };
  }

  /**
   * check if should use mock (memory) db
   */
  public mockDb(): boolean {
    // tslint:disable-next-line:triple-equals
    return this.dbConfig().OADB_SERVICE == 'mock';
  }

}
