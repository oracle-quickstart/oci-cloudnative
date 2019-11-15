import { Controller } from '@nestjs/common';
import { Crud } from '@nestjsx/crud';

import { ROUTE } from '../../config/constants';
import { UserAddress } from './address/address.entity';
import { AddressService } from './address/address.service';
import { BaseAddressController } from './address/address.base.controller';

/**
 * User/address relation controller
 * /customers/:userId/addresses
 */
@Crud({
  model: {
    type: UserAddress,
  },
  params: {
    userId: {
      field: 'userId',
      type: 'uuid',
    },
  },
})
@Controller(`/${ROUTE.USERS}/:userId/${ROUTE.ADDRESSES}`)
export class UserAddressController extends BaseAddressController {
  constructor(public service: AddressService) {
    super(service);
  }
}
