/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

import { Mu } from '../mu';
import { MUSHOP } from './constants';

export class ConfigController {
  constructor() {
    this.load = this.load.bind(this);
    this.mu.on('ready', this.load);
  }

  load() {
    this._c = this.mu.http.get('/config')
      .then(({ data }) => data)
      .catch(() => ({}));
    return this.get();
  }

  get() {
    return this._c || this.load();
  }
  
}

export default Mu.macro(MUSHOP.MACRO.CONFIG, ConfigController);
