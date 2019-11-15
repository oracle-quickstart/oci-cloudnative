
import { CrudController } from '@nestjsx/crud';
import { UserAddress } from './address.entity';
import { AddressService } from './address.service';

export abstract class BaseAddressController implements CrudController<UserAddress> {
  constructor(public service: AddressService) {}

  /**
   * get typed base class
   */
  get base(): CrudController<UserAddress> {
    return this;
  }
}
