import { SelectQueryBuilder, EntityManager } from 'typeorm';
import { Logger } from '@nestjs/common';

export interface MockQueryConditions {
  limit?: number;
  offset?: number;
  where?: {[key: string]: any};
  fields?: string[];
}

/**
 * Extends the TypeORM query builder to reverse map query expressions
 * into JSON options
 */
export class MockQueryBuilder extends SelectQueryBuilder<any> {
  public static create(entity: any, name: string, manager: EntityManager) {
    const that = new this(entity, name, manager);
    return that;
  }

  private logger = new Logger(this.constructor.name);
  constructor(
    private readonly entity: any,
    private readonly name: any,
    private readonly manager: EntityManager) {
    super(null);
  }

  /**
   * prevents actually trying to execute any query
   */
  async execute() { this.logger.debug('noop query execution'); }

  /**
   * Called by @Crud list
   */
  async getMany() {
    this.logger.debug('GET MANY');
    const options = this.toMockOptions();
    this.logger.debug(options);
    return await this.manager.find(this.entity, options);
  }

  /**
   * Called by @Crud get
   */
  async getOne() {
    this.logger.debug('GET ONE');
    const options = this.toMockOptions();
    return await this.manager.findOne(this.entity, options);
  }

  /**
   * converts the SQL expression map to conditions processable by the entity manager
   */
  private toMockOptions(): MockQueryConditions {
    const { selects, take: limit, skip: offset, wheres, parameters } = this.expressionMap;
    // determine fields
    const fields = selects
      .map(({selection}) => selection.replace(`${this.name}.`, ''));
    // determine conditions
    const where = Object.assign({}, ...wheres.map(({ condition }) => {
      // ex => 'User.id = :someParamName'
      const field = condition.match(new RegExp(`${this.name}\\.([\\w-]+)`))[1];
      const param = condition.match(/:([\w]+)$/)[1];
      return { [field]: parameters[param] };
    }));

    return { fields, limit, offset, where };
  }
}
