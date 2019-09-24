import { Controller } from '@nestjs/common';
import { Crud, Override, ParsedRequest, ParsedBody, CrudRequest } from '@nestjsx/crud';

import { ROUTE } from '../../../config/constants';
import { UserCard } from './card.entity';
import { CardService } from './card.service';
import { BaseCardsController } from './card.base.controller';

/**
 * Standard CRUD for /cards
 */
@Crud({
  model: {
    type: UserCard,
  },
  routes: {
    only: ['getOneBase'],
  },
})
@Controller(ROUTE.CARDS)
export class CardsController extends BaseCardsController {

  constructor(public service: CardService) {
    super(service);
  }

  /**
   * Card creation
   * @param req
   * @param dto
   */
  @Override()
  createOne(@ParsedRequest() req: CrudRequest, @ParsedBody() dto: UserCard) {
    return super.createOne(req, dto);
  }
}
