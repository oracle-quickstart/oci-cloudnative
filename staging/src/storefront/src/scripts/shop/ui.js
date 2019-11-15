/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

import { Mu, MuMx, attrToSelector, MuCtxSetterMixin } from '../mu';
import { getGlobal } from '../util/window';
import { UI_GLOBAL } from '../util/constants';
import { MUSHOP } from './constants';

export class MuUi {
  constructor() {
    this.kit = getGlobal(UI_GLOBAL);
    // this.view.on('attached', this.kit.update.bind(this.kit));
    ['alert', 'dialog', 'confirm'].forEach(m => this[m] = msg => this.kit.modal[m](msg));
  }

  notification(msg, options) {
    return this.kit.notification(msg, options);
  }

  alert(msg) {
    return this.kit.modal.alert(msg);
  }

  dialog(msg) {
    return this.kit.modal.dialog(msg);
  }
}

const UkComponentAttr = 'mu-uk-component';
export class UKComponent extends MuMx.compose(null, [MuCtxSetterMixin, UkComponentAttr]) {

  onDispose() {
    super.onDispose();
    // ensure the node is removed (incase ui-kit relocates with dom manipulations)
    const { parentNode } = this.node;
    return parentNode && parentNode.removeChild(this.node);
  }

  valueForCtx(attr) {
    return this.ukComponent();
  }

  /**
   * connect the UIkit JavaScript component api
   */
  ukComponent() {
    const uk = this.mu.ui.kit;
    const ukReg = /^uk-/;
    const ukComponent = this.node.getAttributeNames()
      .filter(n => ukReg.test(n))
      .map(n => n.replace(ukReg, ''))
      .shift();
    return ukComponent && uk[ukComponent] && uk[ukComponent](this.node);
  }

}

export default Mu.macro(MUSHOP.MACRO.UI, MuUi)
  .micro(UKComponent, attrToSelector(UkComponentAttr));

