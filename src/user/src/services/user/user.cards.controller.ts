import { Controller } from '@nestjs/common';
import { Crud, Override, ParsedRequest, ParsedBody, CrudRequest } from '@nestjsx/crud';

import { ROUTE } from '../../config/constants';
import { UserCard } from './card/card.entity';
import { CardService } from './card/card.service';
import { BaseCardsController } from './card/card.base.controller';

/**
 * User/cards relation controller
 * /customers/:userId/cards
 */
@Crud({
  model: {
    type: UserCard,
  },
  params: {
    userId: {
      field: 'userId',
      type: 'uuid',
    },
  },
})
@Controller(`/${ROUTE.USERS}/:userId/${ROUTE.CARDS}`)
export class UserCardsController extends BaseCardsController {

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
