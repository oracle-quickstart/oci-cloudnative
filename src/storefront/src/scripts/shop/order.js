import { Mu, MuMx, attrToSelector } from '../mu';
import { ViewTemplateMixin } from './helper/viewmx';
import { MxCtxInsulator } from './helper/mixins';

export class OrderController {
  constructor() {
    this._normalize = this._normalize.bind(this);
  }

  _normalize(order) {
    const { router } = this.mu;
    order.id = order.id || order._links.self.href.split('/').pop();
    order.humanId = order.id.slice(-11);
    order.href = router.href('orders', { id: order.id });
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
    } else {
      return Promise.reject(res.data.status_text);
    }
  }
  
  create() {
    const { api, cart } = this.mu;
    return api.post('/orders')
      .then(res => this._res(res))
      .then(order => cart.empty().then(() => order));
  }

  get(id) {
    return this.mu.api.get(`/orders/${id}`)
      .then(res => this._res(res));
  }

  list() {
    return this.mu.api.get('/orders')
      .then(res => res.data.map(this._normalize));
  }
}

const ORDER_MU = {
  CHECKOUT: 'mu-checkout',
  ORDERS: 'mu-orders',
};

export class MuCheckout extends MuMx.compose(null,
  MxCtxInsulator,
  ViewTemplateMixin,
) {
  constructor() {
    super();
    this.context.set('checks', {});
  }

  onMount() {
    super.onMount();
    this.render({
      onCard: card => this.setCheck({ card }),
      onAddress: address => this.setCheck({ address }),
      onCartItems: items => this.setCheck({ items }),
      canCheckout: this.canCheckout.bind(this),
      handleSubmit: this.submitOrder.bind(this),
    });
  }

  setCheck(check) {
    const checks = this.context.get('checks');
    Object.assign(checks, check);
    this.refresh();
  }

  refresh() {
    const didRefresh = this.context.get('didRefresh');
    if (!didRefresh) {
      const ready = this.canCheckout();
      return ready && this.render({ didRefresh: true });
    }
  }

  canCheckout() {
    const { submitting, checks: { items, address, card } } = this.context.get();
    const ready = (items && items.length) &&
        !!address && 
        !!card;
    // console.log('check ready', ready, shopCart);
    return !submitting && ready;
  }

  submitOrder() {
    const { order, router } = this.mu; 
    return this.render({ submitting: true })
      .then(() => order.create())
      .then(o => router.go('orders', { id: o.id }))
      .catch(error => this.render({ error, submitting: false }));
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
      .then(orders => this.render({ orders, loading: false}))
      .catch(error => this.render({ error, loading: false}));
  }
}

export default Mu.macro('order', OrderController)
  .micro('order.checkout', attrToSelector(ORDER_MU.CHECKOUT), MuCheckout)
  .micro('order.orders', attrToSelector(ORDER_MU.ORDERS), MuOrders);

