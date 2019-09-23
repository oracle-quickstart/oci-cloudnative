/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

import { Mu, MuMx } from '../mu';
import { MuCtxSingleAttrMixin, MuCtxAttrMixin, MuCtxInheritOnly, MxCtxAttrRefresh } from '../bindings';
import { attrToSelector } from '../util';

const LOGICAL_ATTR = {
  ATTR: 'mu-attr',
  HIDE: 'mu-hide',
  CLASS: 'mu-class',
  EACH: 'mu-each',
  HTML: 'mu-html',
  IF: 'mu-if',
  // TODO:
  // SWITCH: 'mu-switch',
  // GLOBAL: 'mu-global',
};


/**
 * MuIF micro - conditional display based on context property
 */
export class MuIF extends MuMx.compose(null,
  MuCtxInheritOnly,
  [MxCtxAttrRefresh, LOGICAL_ATTR.IF],
) {

  onMount() {
    const { parentNode } = this.node;
    const virtual = this.view.virtual();
    this.placeholder = virtual.createComment(`${LOGICAL_ATTR.IF} ${this._ctxAttrProp()}`);
    // create placeholder target and remove the source node
    parentNode.insertBefore(this.placeholder, this.node);
    parentNode.removeChild(this.node);

    return super.onMount();
  }

  onDispose() {
    this.falsy();
    const { parentNode } = this.placeholder;
    parentNode && parentNode.removeChild(this.placeholder);
    return super.onDispose();
  }

  falsy() {
    const { current, placeholder } = this;
    const { parentNode } = placeholder;
    if (current) {
      // console.log('dispose if', this._ctxAttrProp(), current, parentNode);
      this.view.dispose(current);
      this.current = null;
      return parentNode && 
        parentNode.contains(current) && 
        parentNode.removeChild(current);
    }
  }

  getOriginal() {
    // clone the original node for re-use
    const c = this.node.muOriginal();
    c.removeAttribute(LOGICAL_ATTR.IF); // prevent re-binding
    return c;
  }

  refresh() {
    // make async
    return Promise.resolve(this._ctxAttrBool())
      .then(test => {
        const { current, placeholder } = this;
        const exist = current && !!current.parentNode;
        this.falsy();
        if (test) {
          const { parentNode } = placeholder;
          const fresh = this.getOriginal();
          // render fresh
          const virtual = this.current = this.view.virtualContainer();
          virtual.appendChild(fresh);
          this.view.attach(virtual, this.context);
          
          return parentNode && parentNode.insertBefore(fresh, placeholder);
        }
      });
  }
}

/**
 * MuEach micro
 * @example
 * <li mu-each="things" mu-each-as="item">
 *   <a mu-html="item"></a>
 * </li>
 */
export class MuEach extends MuMx.compose(null,
  MuCtxInheritOnly,
  [MxCtxAttrRefresh, LOGICAL_ATTR.EACH],
) {

  onInit() {
    this.eachNodes = [];
    return super.onInit();
  }

  onMount() {
    // capture some ivars
    const { parentNode } = this.node;

    const virtual = this.view.virtual();
    this.placeholder = virtual.createComment(`${LOGICAL_ATTR.EACH} ${this._ctxKey()}`);
    parentNode.insertBefore(this.placeholder, this.node);
    parentNode.removeChild(this.node);

    // console.log('MOUNTED each', this.original);
    return super.onMount();
  }

  getOriginal() {
    // clone the original node for re-use
    const c = this.node.muOriginal();
    c.removeAttribute(LOGICAL_ATTR.EACH); // prevent re-binding
    return c;
  }

  refresh() {
    const val = this._ctxAttrValue();
    // dispose old
    this.eachNodes = this.eachNodes.reduce((empty, old) => {
      const { virtual, node, node: { parentNode }} = old;
      parentNode && parentNode.removeChild(node);
      this.view.dispose(virtual, true);
      return empty;
    }, []);
    
    // resolve new value
    // NOTE, because this is a promise, a parent context will bypass the nodes
    return Promise.resolve(typeof val === 'function' ? val() : val)
      .then(items => {
        if (items && items.length) {
          const copy = this.getOriginal();
          const itemAs = copy.getAttribute('mu-each-as') || this._ctxKey();
          const { parentNode } = this.placeholder;

          // create virtual bumper
          const bumper = this.view.virtualContainer();
          parentNode.insertBefore(bumper, this.placeholder);

          // populate virtual node with items
          items.reduce((prev, item, index) => {
            // create new freshy after the last (or bumper)
            const fresh = this.getOriginal();
            const virtual = this.view.virtualContainer();
            virtual.appendChild(fresh);
            
            // attach the view
            this.view.attach(virtual, this.context.child({
              [this._ctxKey()]: null, // remove list from context
              [itemAs]: item,      // single list item
              index,
            }));
            prev.insertAdjacentElement("afterend", fresh);

            // keep node in memory for GC
            this.eachNodes.push({
              virtual,
              node: fresh,
            });
            // new bumper
            return fresh;
          }, bumper);

          parentNode.removeChild(bumper);
        }
      });
  }
}

/**
 * MuAttr micro - sets the the node attributes from context
 * @example
 * <input name="name" mu-attr mu-attr-value="fields.name" />
 */
export class MuAttr extends MuMx.compose(null, MuCtxInheritOnly, MuCtxAttrMixin) {

  onInit() {
    this.refresh = this.refresh.bind(this);
  }

  onMount() {
    this.refresh();
    this.getAttrs().forEach(p =>
      this.context.on(this._ctxKey(p.src), this.refresh));
  }

  onDispose() {
    this.getAttrs().forEach(p => 
      this.context.off(this._ctxKey(p.src), this.refresh));
  }

  getAttrs() {
    const reg = new RegExp(`^${LOGICAL_ATTR.ATTR}-([\\w-]+)`);
    // resolve all matching attr bindings
    return this.node.getAttributeNames()
      .filter(n => reg.test(n))
      .map(src => ({ src, to: src.replace(reg, '$1') }));
  }

  refresh() {
    const bools = ['disabled', 'checked', 'selected', 'hidden'];
    this.getAttrs().forEach(p => {
      const bool = !!~bools.indexOf(p.to);
      const val = bool ? this._ctxAttrBool(p.src) : this._ctxAttrValue(p.src);
      return (val || val === 0) ? this.node.setAttribute(p.to, val) : this.node.removeAttribute(p.to);
    });
  }
}

/**
 * MuHide micro - hides the element based on context conditions
 * @example
 * <div mu-hide="true">hidden</div>
 */
export class MuHide extends MuMx.compose(null, [MxCtxAttrRefresh, LOGICAL_ATTR.HIDE]) {

  refresh() {
    const test = this._ctxAttrBool();
    const attr = 'hidden';
    return test ?
      this.node.setAttribute(attr, true) :
      this.node.removeAttribute(attr);
  }

}


/**
 * MuHtml micro
 * @example
 * <div mu-html="ctx.html"></div>
 */
export class MuHtml extends MuMx.compose(null,
  MuCtxInheritOnly,
  [MxCtxAttrRefresh, LOGICAL_ATTR.HTML],
) {

  refresh() {
    const val = this._ctxAttrValue();
    return Promise.resolve(typeof val === 'function' ? val() : val)
      .then(html => this.view.apply(this.node, html || '', this.context));
  }
}


export class MuClassLogical extends MuMx.compose(null,
  MuCtxInheritOnly,
  [MuCtxSingleAttrMixin, LOGICAL_ATTR.CLASS]
) {

  onInit() {
    this.refresh = this.refresh.bind(this);
  }

  onMount() {
    this._rules().forEach(rule => this.context.on(rule.key, this.refresh));
    this.refresh();
  }

  onDispose() {
    this._rules().forEach(rule => this.context.off(rule.key, this.refresh));
  }

  _rules() {
    try {
      const rules = this._ctxAttrValue() || JSON.parse(this._ctxAttrProp().replace(/['"]/g,'"'));
      return Object.keys(rules)
        .map(k => ({
          exp: rules[k],
          key: this._ctxAttrPropKey(rules[k]),
          classNames: k.split(/\s+/),
        }));
    } catch (e) {
      // console.warn(this.constructor.name, e);
      return [];
    }
  }

  refresh() {
    const { classList } = this.node;
    const rules = this._rules();
    classList.remove(...[].concat(rules.map(r => r.classNames)));
    rules.forEach(rule => this._ctxBool(rule.exp) && classList.add(...rule.classNames));
  }
}

export default Mu.core(MuAttr, attrToSelector(LOGICAL_ATTR.ATTR))
  .core(MuEach, attrToSelector(LOGICAL_ATTR.EACH))
  .core(MuIF, attrToSelector(LOGICAL_ATTR.IF))
  .core(MuHide, attrToSelector(LOGICAL_ATTR.HIDE))
  .core(MuClassLogical, attrToSelector(LOGICAL_ATTR.CLASS))
  .core(MuHtml, attrToSelector(LOGICAL_ATTR.HTML));