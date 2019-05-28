import { MuMx, MuCtxAttrMixin } from "../../mu";

/**
 * Mixin for /views/{viewName} rendering
 * @param {function} ctor 
 * @param {string} attr - selector attribute
 * @param {string} [viewName] - static remote view name
 */
export const ViewTemplateMixin = (ctor, attr, viewName) => 
class extends MuMx.compose(ctor, MuCtxAttrMixin) {

  onMount() {

    // determine view
    this._remoteView = viewName || // explicitly defined by mixin
      this._ctxAttrValue(attr) || // value from context (dynamic)
      this._ctxAttrProp(attr) ||  // value from attribute string
      this.viewTemplateDelegate(); // delegated to child
    this._localView = !this._remoteView && this.node.muOriginal().innerHTML;
    
    // clear contents until render happens
    this.node.innerHTML = '';
    return super.onMount && super.onMount();
  }

  onDispose() {
    const { parentNode } = this.node;
    if (parentNode) {
      parentNode.removeChild(this.node);
    }
    return super.onDispose && super.onDispose();
  }

  viewTemplateDelegate() {

  }

  render(data) {
    const view = this._localView || this._remoteView;
    const renderMethod = this._localView ? 'render': 'renderRemote';
    this._viewDidRender = true;
    return view && this.view[renderMethod](this.node, view, this.context.extend(data));
  }
  
}
