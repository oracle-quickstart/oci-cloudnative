import { Controller, Request, Post, UseGuards, UseInterceptors, Body, HttpException, HttpStatus } from '@nestjs/common';
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
  async register(@ParsedRequest() req: CrudRequest, @Body() dto: User) {
    const exist = await this.service.findByUsername(dto.username);
    if (exist) {
      throw new HttpException({
        status: HttpStatus.CONFLICT,
        error: 'Username already exists',
      }, 409);
    }
    return this.service.createOne(req, User.hashPassword(dto))
      .then(user => this.service.filterDTO(user));
  }

}
