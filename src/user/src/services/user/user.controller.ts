import { Controller } from '@nestjs/common';
import { Crud, CrudController, Override, ParsedRequest, ParsedBody, CrudRequest } from '@nestjsx/crud';

import { User, USER_EXCLUDES } from './user.entity';
import { UserService } from './user.service';
import { ROUTE } from '../../config/constants';

@Crud({
  model: {
    type: User,
  },
  query: {
    exclude: USER_EXCLUDES,
    join: {
      addresses: { },
      cards: { },
    },
  },
})
@Controller(ROUTE.USERS)
export class UsersController implements CrudController<User> {
  constructor(public service: UserService) {}

  /**
   * get typed base class
   */
  get base(): CrudController<User> {
    return this;
  }

  /**
   * User creation / (registration)
   * @param req
   * @param dto
   */
  @Override()
  createOne(@ParsedRequest() req: CrudRequest, @ParsedBody() dto: User) {
    return this.base.createOneBase(req, User.hashPassword(dto))
      .then(user => this.service.filterDTO(user));
  }

  /**
   * Custom PATCH /:id
   * @param req
   * @param dto
   */
  @Override()
  updateOne(@ParsedRequest() req: CrudRequest, @ParsedBody() dto: User) {
    return this.base.updateOneBase(req, User.hashPassword(dto))
      .then(user => this.service.filterDTO(user));
  }

  /**
   * Custom PUT /:id
   * @param req
   * @param dto
   */
  @Override()
  replaceOne(@ParsedRequest() req: CrudRequest, @ParsedBody() dto: User) {
    return this.base.replaceOneBase(req, User.hashPassword(dto))
      .then(user => this.service.filterDTO(user));
  }
}
