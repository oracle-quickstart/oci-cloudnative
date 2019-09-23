/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

import { Mu, MuMx, MuCtxSingleAttrMixin, attrToSelector } from '../../mu';

const DEBUG_ATTR = 'mu-debug';

export class MuDebug extends MuMx.compose(null, [MuCtxSingleAttrMixin, DEBUG_ATTR]) {
  onInit() {
    this.render = this.render.bind(this);
  }

  onMount() {
    this._prop = this._ctxAttrProp();
    this.context.always(this._prop, this.render);
  }

  onDispose() {
    this.context.off(this._prop, this.render);
  }

  render(val) {
    return this.view.render(this.node, `<pre>{{pre}}</pre>`, {
      pre: JSON.stringify({ [this._prop]: val }, null, 2)
    });
  }
}

export default Mu.micro(MuDebug, attrToSelector(DEBUG_ATTR));