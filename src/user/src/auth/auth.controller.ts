import { Controller, Request, Post, UseGuards, UseInterceptors, Body } from '@nestjs/common';
import { ParsedRequest, CrudRequest, CrudRequestInterceptor } from '@nestjsx/crud';
import { AuthGuard } from '@nestjs/passport';

import { User } from '../services/user/user.entity';
import { UserService } from '../services/user/user.service';
import { ROUTE } from '../config/constants';

@Controller()
export class AuthController {
  constructor(public service: UserService) {}

  /**
   * User authentication
   * @param req
   */
  @UseGuards(AuthGuard('local'))
  @Post(ROUTE.LOGIN)
  async login(@Request() req) {
    return req.user;
  }

  /**
   * alias for POST / customer registration
   * @param req
   * @param dto
   */
  @UseInterceptors(CrudRequestInterceptor)
  @Post(ROUTE.REGISTER)
  register(@ParsedRequest() req: CrudRequest, @Body() dto: User) {
    return this.service.createOne(req, User.hashPassword(dto))
      .then(user => this.service.filterDTO(user));
  }

}
