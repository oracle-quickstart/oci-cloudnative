/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

import { Mu, MuMx, attrToSelector } from '../mu';
import { ViewTemplateMixin } from './helper/viewmx';
import { MxCtxInsulator } from './helper/mixins';
import { MUSHOP } from './constants';

export class OrderController {
  constructor() {
    this._normalize = this._normalize.bind(this);
  }

  _normalize(order) {
    const { router } = this.mu;
    order.id = order.id || order.orderId || order._links.self.href.split('/').pop();
    order.humanId = ('0000000000' + order.id).slice(-11);
    order.href = router.href('orders', { id: order.id });
    order.date = order.date || order.orderDate;
    // order.shortDate = new Date(order.date).toDateString();
    order.shortDate = order.date.split('.').shift().replace('T', ' ');
    // totals
    order.totalPrice = order.total.toFixed(2);
    order.totalSize = order.items.map(item => item.quantity || 1)
      .reduce((total, qty) => total + qty, 0);
    // payment
    order.paymentMethod = 'Credit Card';
    order.paymentCard = order.card.longNum.slice(-4);
    // status
    order.status = order.shipment ? 'Shipped' : 'Processing';
    return order;
  }

  _res(res) {
    if (res.data && !(res.data.status_code > 200)) {
      return this._normalize(res.data);
    } else if (res.data) {
      return Promise.reject(`${res.data.status_text}: ${res.data.error}`);
    } else {
      return Promise.reject(`Not Found`);
    }
  }
  
  create() {
    const { http, cart } = this.mu;
    return http.post('/orders')
      .then(res => this._res(res))
      .then(order => cart.empty().then(() => order));
  }

  get(id) {
    return this.mu.http.get(`/orders/${id}`)
      .then(res => this._res(res));
  }

  list() {
    return this.mu.http.get('/orders')
      .then(res => res.data.map(this._normalize));
  }
}

const ORDER_MU = {
  CHECKOUT: 'mu-checkout',
  ORDERS: 'mu-orders',
};

export class MuCheckout extends MuMx.compose(null,
  MxCtxInsulator,
  ViewTemplateMixin) {

  constructor() {
    super();
    this.context.set('checks', {});
  }

  onMount() {
    super.onMount();
    this.render({
      onCard: card => this.setCheck('card', card),
      onAddress: address => this.setCheck('address', address),
      onCartItems: items => this.setCheck('items', items),
      canCheckout: this.canCheckout(),
      handleSubmit: this.submitOrder.bind(this),
    });
  }

  setCheck(check, value) {
    this.context.set(`checks.${check}`, value);
    this.refresh();
  }

  refresh() {
    this.context.set('canCheckout', this.canCheckout());
  }

  canCheckout() {
    const { submitting, checks: { items, address, card } } = this.context.get();
    const ready = (items && items.length) &&
        !!address && 
        !!card;
    return !submitting && ready;
  }

  submitOrder() {
    const { order, router } = this.mu; 
    return this.render({ submitting: true })
      .then(() => order.create())
      .then(o => router.go('orders', { id: o.id }))
      .catch(e => {
        // console.log(error, JSON.stringify(error.response, null, 2));
        const r = e.response || {};
        const error = (r && r.data && r.data.message) || e;
        this.render({ error, submitting: false });
      });
  }
}

export class MuOrders extends MuMx.compose(null, ViewTemplateMixin) {
  onMount() {
    super.onMount();
    this.load();
  }

  load() {
    const { order, router } = this.mu;
    const { id } = router.queryparams() || {};
    const get = () => id ? Promise.all([order.get(id)]) : order.list();
    this.render({ loading: true })
      .then(() => get())
      .then(orders => this.render({ 
        orders,
        noHistory: !orders.length,
        loading: false,
      }))
      .catch(error => this.render({ error, loading: false }));
  }
}

export default Mu.macro(MUSHOP.MACRO.ORDER, OrderController)
  .micro(MuCheckout, attrToSelector(ORDER_MU.CHECKOUT))
  .micro(MuOrders, attrToSelector(ORDER_MU.ORDERS));

