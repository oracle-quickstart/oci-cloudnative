/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

import { Mu, MuMx, MuCtxSetterMixin } from '../mu';
import { ShopMxSubscriber } from './helper/subscriber';
import { Badge } from './components/badge';
import { ViewTemplateMixin } from './helper/viewmx';
import { MxCtxInsulator } from './helper/mixins';
import { MUSHOP } from './constants';

// some fixed business info
const CART = {
  SHIPPING_STANDARD: 4.99,
  FREE_THRESHOLD: 10000, // shipping is fixed :(
  TAX_RATE: 0,
};

export class CartController {
  constructor() {
    this.load = this.load.bind(this);
    this.mu.on('ready', () => this.mu.user.always('user.profile', this.load));
  }

  _conditioner(items) {
    return items.map(item => ({
      ...item,
      rowUnitPrice: item.unitPrice.toFixed(2),
      rowTotalPrice: (item.quantity * item.unitPrice).toFixed(2),
    }));
  }

  _setCart(items) {
    this.data = this._conditioner(items);
    this.combinedData = null;
    this.emit('contents', this.data);
    return this.data;
  }

  load() {
    this.mu.http.get('/cart')
      .then(res => this._setCart(res.data))
      .catch(e => this.emit('error', e));
  }

  add(item, quantity) {
    const { http, ui } = this.mu;
    const { id, name } = item; 
    return http.post('/cart', { id, quantity })
      .then(this.load)
      .then(() => ui.notification(`${name} added to cart!`, {
        status: 'success',
        timeout: 2e3
      }));
  }

  update(item, quantity) {
    const { id } = item;
    return this.mu.http.post('/cart/update', { id, quantity })
      .then(this.load);
  }

  remove(item) {
    const id = typeof item === 'string' ? item : item.id;
    return this.mu.http.delete(`/cart/${id}`)
      .then(this.load);
  }

  empty() {
    this.data = null;
    return this.mu.http.delete('/cart')
      .then(this.load);
  }

  contents() {
    return this.data || [];
  }

  size() {
    return this.contents()
      .map(item => item.quantity || 1)
      .reduce((total, qty) => total + qty, 0);
  }

  /**
   * compute cart total
   */
  totals() {
    const subtotal = this.contents()
      .map(item => (item.quantity || 1) * item.unitPrice)
      .reduce((total, line) => total + line, 0);
    let discounts = 0;
    const tax = subtotal * CART.TAX_RATE;
    const shipRate = subtotal ? CART.SHIPPING_STANDARD : 0;
    let shipping = shipRate;
    if( subtotal >= CART.FREE_THRESHOLD) {
      discounts += shipping;
      shipping = 0;
    }
    const total = subtotal + tax + shipping;

    return { subtotal, shipRate, shipping, discounts, tax, total };
  }

  /**
   * Get cart totals as formatted currency decimal
   */
  totalsToFixed() {
    const totals = this.totals();
    Object.keys(totals).forEach(k => totals[k] = totals[k].toFixed(2));
    return totals;
  }

  /**
   * get cart contents combined with catalog product information
   */
  combined() {
    // resolve with corresponding sku records from catalog svc
    const { catalog } = this.mu;
    const contents = this.contents();
    
    this.combinedData = this.combinedData || Promise.all(contents.map(item => catalog.product(item.itemId)))
      // map to {[id]: product} hash
      .then(products => Object.assign({}, ...products.map(p => ({[p.id]: p}))))
      // map to a new object for mixed use
      .then(pMap => contents.map(item => ({
        item,
        product: pMap[item.itemId],
        actions: {
          update: this.update.bind(this, pMap[item.itemId]),
          remove: this.remove.bind(this, pMap[item.itemId]),
        }
      })));
    return this.combinedData;
  }
}

class CartSubscriber extends MuMx.compose(null, ShopMxSubscriber) {
  constructor() {
    super();
    this.listener = this.listener.bind(this);
    this.subscribeAlways('contents', this.mu.cart, this.listener)
      .subscribeAlways('error', this.mu.cart, this.listener);
  }

  listener(cart) {
    
  }
}

/**
 * off canvas cart
 */
export class MuCart extends MuMx.compose(CartSubscriber,
  MxCtxInsulator,
  ViewTemplateMixin,
) {
  
  viewTemplateDelegate() {
    // source the template remotely from the property, || use node.innerHTML
    return this._ctxProp('template') || null;
  }

  listener() {
    // const cartCtl = this.mu.cart;
    const { cart } = this.mu;
    const size = cart.size();
    const rawTotals = cart.totals();
    const totals = cart.totalsToFixed();

    const cb = this._ctxAttrValue('onItems');

    // load corresponding sku records
    return this.render({ loading: true }, true)
      .then(() => cart.combined())
      .then(items => items.map(row => ({
        ...row,
        // qty manipulation bindings
        qty: {
          inc: this.increment.bind(this, row, 1),
          dec: this.increment.bind(this, row, -1),
          change: this.qtyChange.bind(this, row),
        }
      })))
      .then(items => this.render({
        loading: false,
        items,
        size,
        isEmpty: !size,
        totals,
        rawTotals,
      }).then(() => cb && cb(items)));
  }

  increment(row, amnt) {
    const { item: { quantity } } = row;
    const v = Math.max(1, quantity + amnt);
    return this.updateRow(row, v);
  }

  qtyChange(row, e) {
    const v = Math.max(1, ~~e.target.value);
    e.target.value = v;
    return this.updateRow(row, v);
  }

  updateRow(row, qty) {
    return this.render({ loading: true })
      .then(() => row.actions.update(qty));
  }

}

/**
 * Cart contents badge indicator
 */
export class CartBadge extends CartSubscriber {

  onMount() {
    this.badge = new Badge(this.node, this.view);
    super.onMount();
  }

  listener(cart) {
    this.badge.render(this.mu.cart.size());
  }
}

export default Mu.macro(MUSHOP.MACRO.CART, CartController)
  .micro(MuCart, '[mu-cart]')
  .micro(CartBadge, '[mu-cart-badge]');