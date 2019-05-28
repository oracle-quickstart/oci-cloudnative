import { Mu, MuMx, attrToSelector, MuCtxSetterMixin } from '../mu';
import { getGlobal } from '../util/window';
import { UI_GLOBAL } from '../util/constants';

export class MuUi {
  constructor() {
    this.kit = getGlobal(UI_GLOBAL);
    // this.view.on('attached', this.kit.update.bind(this.kit));
  }

  notification(msg, options) {
    return this.kit.notification(msg, options);
  }
}

const UkComponentAttr = 'mu-uk-component';
export class UKComponent extends MuMx.compose(null, [MuCtxSetterMixin, UkComponentAttr]) {
  // onMount() {
  //   this.mu.ui.kit.update(this.node);
  //   return super.onMount && super.onMount();
  // }


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
    const ukReg = /^uk\-/;
    const ukComponent = this.node.getAttributeNames()
      .filter(n => ukReg.test(n))
      .map(n => n.replace(ukReg, ''))
      .shift();
    return ukComponent && uk[ukComponent] && uk[ukComponent](this.node);
  }

}

export default Mu.macro('ui', MuUi)
  .micro('ui.kit', attrToSelector(UkComponentAttr), UKComponent);

