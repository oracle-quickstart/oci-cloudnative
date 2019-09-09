/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

/**
 * Subscriber class mixin
 */
export const ShopMxSubscriber = ctor => class extends ctor {

  constructor(...args) {
    super(...args);
    this._shopMxSubs = new Set();
  }

  /**
   * 
   * @param {*} event 
   * @param {*} publisher 
   * @param {*} listener
   * @param {*} [method] - subscription type (on|one|always)
   */
  subscribe(event, publisher, listener, method) {
    // console.log(`SUBSCRIBE`, event);
    this._shopMxSubs.add({ event, publisher, listener, method });
    return this;
  }

  subscribeOne(event, publisher, listener) {
    return this.subscribe(event, publisher, listener, 'one');
  }

  subscribeAlways(event, publisher, listener) {
    return this.subscribe(event, publisher, listener, 'always');
  }

  onMount() {
    const sup = super.onMount && super.onMount();
    this._shopMxSubs.forEach(sub => sub.publisher[sub.method || 'on'](sub.event, sub.listener));
    return sup;
  }

  onDispose() {
    this._shopMxSubs.forEach(sub => sub.publisher.off(sub.event, sub.listener))
    this._shopMxSubs.clear();
    return super.onDispose && super.onDispose();
  }

}
