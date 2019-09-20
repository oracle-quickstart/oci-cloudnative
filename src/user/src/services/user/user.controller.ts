import { Controller, Request, Post, UseGuards, UseInterceptors, Body } from '@nestjs/common';
import { Crud, CrudController, Override, ParsedRequest, ParsedBody, CrudRequest, CrudRequestInterceptor } from '@nestjsx/crud';
import { AuthGuard } from '@nestjs/passport';

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
   * User authentication
   * @param req
   */
  @UseGuards(AuthGuard('local'))
  @Post('login')
  async login(@Request() req) {
    return req.user;
  }

  /**
   * alias for POST / customer registration
   * @param req
   * @param dto
   */
  @UseInterceptors(CrudRequestInterceptor)
  @Post('register')
  register(@ParsedRequest() req: CrudRequest, @Body() dto: User) {
    return this.createOne(req, dto);
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
