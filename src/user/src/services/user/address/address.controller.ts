// tslint:disable:max-classes-per-file
import { Controller } from '@nestjs/common';
import { Crud } from '@nestjsx/crud';

import { ROUTE } from '../../../config/constants';
import { UserAddress } from './address.entity';
import { AddressService } from './address.service';
import { BaseAddressController } from './address.base.controller';

/**
 * Standard CRUD for /addresses
 */
@Crud({
  model: {
    type: UserAddress,
  },
  routes: {
    only: ['getOneBase'],
  },
})
@Controller(ROUTE.ADDRESSES)
export class AddressController extends BaseAddressController {
  constructor(public service: AddressService) {
    super(service);
  }
}
