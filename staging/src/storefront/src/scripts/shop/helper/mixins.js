/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

import { MuCtxSetterMixin } from "../../mu";

/**
 * Created insulated child context
 */
export const MxCtxInsulator = ctor => class extends ctor {

  constructor(...args) {
    super(...args);
    this.context = this.context.child();
  }

}

/**
 * same as MuCtxSetterMixin, but will default to the parent context, if available
 * @param {*} ctor 
 * @param  {...any} attributes 
 */
export const MxCtxParentSetter = (ctor, ...attributes) => class extends MuCtxSetterMixin(ctor, ...attributes) {
  ctxForProp(attr) {
    return this.context.parent() || this.context;
  }
}
