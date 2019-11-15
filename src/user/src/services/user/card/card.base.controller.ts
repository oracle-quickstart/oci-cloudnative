import { CrudController, CrudRequest } from '@nestjsx/crud';
import { UserCard } from './card.entity';
import { CardService } from './card.service';

export abstract class BaseCardsController implements CrudController<UserCard> {
  constructor(public service: CardService) {}

  /**
   * get typed base class
   */
  get base(): CrudController<UserCard> {
    return this;
  }

  createOne(req: CrudRequest, dto: UserCard): Promise<UserCard> {
    return this.base.createOneBase(req, UserCard.redactNumbers(dto));
  }
}
