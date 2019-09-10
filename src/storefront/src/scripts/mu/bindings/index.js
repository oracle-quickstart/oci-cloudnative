/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

/**
 * mixin to ensure new context is not created during micro binding
 * @param {*} ctor 
 */
export const MuCtxInheritOnly = ctor => {
  ctor.CTX_INHERIT_ONLY = true;
  return ctor;
}

/**
 * Mixin to connect attribute values to context
 * @param {*} ctor 
 */
export const MuCtxAttrMixin = ctor => class extends ctor {

  // getter for ctx property name
  _ctxAttrProp(attr) {
    return attr && this.node.getAttribute(attr);
  }

  // handler to make any changes to the attribute value before reading in context
  _ctxAttrPropKey(str) {
    return (str || '').replace(/^!/, '');
  }
  
  // resolve the context lookup key
  _ctxKey(attr) {
    return this._ctxAttrPropKey(this._ctxAttrProp(attr));
  }

  // getter for the value in ctx
  _ctxAttrValue(attr) {
    const key = this._ctxKey(attr);
    return key && this.context.get(key);
  }

  // determine boolean or not
  _ctxAttrBool(attr) {
    const expression = this._ctxAttrProp(attr);
    return this._ctxBool(expression);
  }

  // evaluate boolean expression
  _ctxBool(expression) {
    const invert = /^!/.test(expression || '');
    const ctxKey = this._ctxAttrPropKey(expression);
    const ctxVal = ctxKey && this.context.get(ctxKey);
    let test = !!ctxVal;
    if (typeof ctxVal === 'function') { // invoke bound test to
      // this is a problem when the flag reprents a conditional method
      // test = ctxVal();
    } else if (!ctxVal && typeof expression === 'string') {
      try { test = JSON.parse(expression); } catch (e) { /* noop */ }
    }
    // TODO: invert if promise?
    return invert ? !test : test;
  }
  
  // resolves either the attribute value, or the string representation
  _ctxProp(attr) {
    return this._ctxAttrValue(attr) || this._ctxAttrProp(attr);
  }

};

/**
 * Mixin to connect a single attribute value to context
 * @param {*} ctor 
 * @param {*} attr 
 */
export const MuCtxSingleAttrMixin = (ctor, attr) => class extends MuCtxAttrMixin(ctor) {
  _ctxAttrProp(a) {
    return super._ctxAttrProp(a || attr);
  }
  _ctxAttrValue(a) {
    return super._ctxAttrValue(a || attr);
  }
}

/**
 * Mixin for single attribute context/refresh subscription
 * @param {*} ctor 
 * @param {*} attr 
 */
export const MxCtxAttrRefresh = (ctor, attr) => class extends MuCtxSingleAttrMixin(ctor, attr) {

  onInit() {
    this.refresh = this.refresh.bind(this);
    return super.onInit && super.onInit();
  }

  onMount() {
    this.context.always(this._ctxKey(), this.refresh);
    return super.onMount && super.onMount();
  }

  onDispose() {
    this.context.off(this._ctxKey(), this.refresh);
    return super.onDispose && super.onDispose();
  }

  refresh() {

  }
}


/**
 * bind attributes to target props in the context
 * @param {*} ctor 
 * @param  {...string} attributes 
 */
export const MuCtxSetterMixin = (ctor, ...attributes) => class extends MuCtxAttrMixin(ctor) {

  onMount() {
    attributes
      .map(attr => ({ attr, prop: this._ctxAttrProp(attr) }))
      .filter(m => m.prop)
      .forEach(m => this.ctxForProp(m.attr).set(m.prop, this.valueForCtx(m.attr)));
    return super.onMount && super.onMount();
  }

  onDispose() {
    attributes
      .map(attr => ({ attr, prop: this._ctxAttrProp(attr) }))
      .filter(m => m.prop)
      // .forEach(m => this.ctxForProp(m.attr).set(m.prop, null));
      .forEach(m => this.ctxForProp(m.attr).delete(m.prop));
    return super.onDispose && super.onDispose();
  }

  /**
   * Can be overidden to supply alternate context
   * @param {*} attr 
   */
  ctxForProp(attr) {
    return this.context;
  }

  /**
   * This should be implemented for each unique attribute specified in the factory
   */
  valueForCtx(attr) {
    return this;
  }

};

/**
 * 
 * @param {function} ctor 
 * @param  {...[string, string]} tuples - map of the [attributeName, eventName]
 */
export const MuCtxEventBindingMixin = (ctor, ...tuples) => class extends MuCtxAttrMixin(ctor) {
  constructor(...args) {
    super(...args);

    this._ctxEventBindings = tuples.map(([attr, event]) => ({
      attr,
      event: event || attr, // if same,
      handler: this._ctxEventHandler.bind(this, attr),
    }));
  }

  _ctxEventHandler(attr, e) {
    const prop = this._ctxAttrValue(attr);
    return prop && prop(e);
  }

  onMount() {
    this._ctxEventBindings
      .forEach(def => this.node.addEventListener(def.event, def.handler));
    return super.onMount && super.onMount();
  }

  onDispose() {
    this._ctxEventBindings
      .forEach(def => this.node.removeEventListener(def.event, def.handler));
    return super.onDispose && super.onDispose();
  }

};
