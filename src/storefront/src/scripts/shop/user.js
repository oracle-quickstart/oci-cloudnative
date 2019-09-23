/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

import { Mu, MuMx, attrToSelector } from '../mu';
import { ShopMxSubscriber } from './helper/subscriber';
import { ViewTemplateMixin } from './helper/viewmx';
import { MxCtxInsulator } from './helper/mixins';
import { MUSHOP } from './constants';
import { getGlobal } from '../util/window';

export class UserController {
  constructor() {
    this.getUser = this.getUser.bind(this);

    // prepare prop setters
    this._setUser = this._setProp.bind(this, 'profile');
    this._setAddress = this._setProp.bind(this, 'address');
    this._setCard = this._setProp.bind(this, 'card');
    // echo local profile to global context
    this.on('user.profile', p => this.context.set('global.profile', p));
    // initialize user when ready
    this.mu.on('ready', () => {
      this.getUser()
        .then(() => this.context.emit('user.ctx.ready'));
    });
  }

  _clear() {
    this._setUser(null);
    this._setAddress(null);
    this._setCard(null);
    return this;
  }

  _setProp(prop, val) {
    Object.assign(this, {[`_${prop}`]: val});
    this.emit(`user.${prop}`, val);
    return val;
  }

  _userError(err) {
    this._clear().emit('user.error', err);
  }

  _getRes(res, setter) {
    if (res.data && res.data.status_code !== 500) {
      return setter(res.data);
    } else if (res.data) {
      return Promise.reject(`${res.data.status_text}: ${res.data.error}`);
    } else {
      return Promise.reject(`Not Found`);
    }
  }

  _postRes(res) {
    if (res.data && res.data.status_code !== 500) {
      return res.data;
    } else {
      return Promise.reject(res.data.error);
    }
  }

  getUser() {
    // NOTE: the customers service reads from the session cookie and therefore the {id} param is ignored
    // const id = this._user ? this._user.id : 'id';
    return this.mu.http.get(`/profile`)
      .then(res => this._getRes(res, this._setUser))
      .catch(e => this._userError(e))
  }

  register(profile) {
    return this.mu.http.post('/register', profile)
      .then(this.getUser);
  }

  login(username, password) {
    return this.mu.http.get('/login', {
      auth: { username, password }
    }).then(this.getUser);
  }

  logout() {
    this.mu.http.get('/logout')
      .then(() => this._clear())
      .catch(e => this._userError(e));
  }

  /**
   * get user shipping address
   */
  address() {
    return this.mu.http.get('/address')
      .then(res => this._getRes(res, this._setAddress))
      .catch(() => this._setAddress(null));
  }

  /**
   * update user address
   * @param {*} address 
   */
  saveAddress(address) {
    // the "backend" only supports one address
    return Promise.resolve(this.deleteAddress(this._address).catch())
      .then(() => this.mu.http.post('/address', address))
      .then(res => this._postRes(res))
      .then(() => this.address());
  }

  deleteAddress(address) {
    const { id } = address || {};
    return Promise.resolve(id && this.mu.http.delete(`/addresses/${id}`))
      .then(() => this._setAddress(null));
  }

  /**
   * get stored card information
   */
  card() {
    return this.mu.http.get('/card')
      .then(res => this._getRes(res, this._setCard))
      .catch(() => this._setCard(null));
  }

  /**
   * store user card information
   */
  saveCard(card) {
    // the "backend" only supports one card
    return Promise.resolve(this.deleteCard(this._card).catch())
      .then(() => this.mu.http.post('/card', card))
      .then(res => this._postRes(res))
      .then(() => this.card());
  }

  deleteCard(card) {
    const { id } = card || {};
    return Promise.resolve(id && this.mu.http.delete(`/cards/${id}`))
      .then(() => this._setCard(null));
  }
}


export const USER_MU = {
  VIEW: 'mu-user-view',
  TOOLBAR: 'mu-user-toolbar',
  ADDRESS: 'mu-user-address',
  PAYMENT: 'mu-user-payment',
  CUSTOMER: 'mu-customer',
  CONSENT: 'mu-user-consent',
};


/**
 * Mixin for user-dependent /views/{viewName} rendering
 * @param {*} ctor 
 * @param {string} [attr] 
 * @param {string} [viewName] 
 */
export const UserViewMixin = (ctor, attr, viewName) => class extends MuMx.compose(ctor,
  MxCtxInsulator,
  ShopMxSubscriber,
  [ViewTemplateMixin, attr, viewName]) {

  constructor() {
    super();
    // listen to user change
    this.subscribeAlways('user.profile', this.mu.user, this._dataUpdate.bind(this, 'profile'));
  }

  _dataUpdate(prop, data) {
    if (prop === 'profile') {
      const { router } = this.mu;
      this.context.set('href.account', router.href('customer', { id: data && data.id }));
    }
    // support callbacks as well: onProfile, onAddress, onCard
    const cbProp = 'on' + prop.charAt(0).toUpperCase() + prop.slice(1);
    const cb = this._ctxAttrValue(cbProp);
    return this.render({ [prop]: data }).then(() => cb && cb(data));
  }

  loading(loading) {
    return this.context.extend({ 
      loading,
      error: null,
    });
  }
}

/**
 * arbitrary any user view to load `profile` into the context
 * @example
 * <div mu-user-view></div>
 */
export class UserView extends MuMx.compose(null, [UserViewMixin, USER_MU.VIEW]) {

}

/**
 * Specific user-control for toolbar/off-canvas login + registration
 */
export class UserToolbar extends MuMx.compose(null, [UserViewMixin, null, 'userToolbar.html']) {

  onInit() {
    // view context bindings
    // console.log('TOOLBAR SUBSCRIBING', this.context._id);
    this.subscribe('form.auth', this.context, f => f && f.one('submit', this.submitAuth.bind(this)))
      .subscribe('form.reg', this.context, f => f && f.one('submit', this.submitReg.bind(this)));
  }

  onMount() {
    this.context.extend({
      inline: this._ctxAttrBool('inline'),
      offcanvas: this.node.getAttribute(USER_MU.TOOLBAR) === 'offcanvas',
    });
    return super.onMount();
  }

  success(message) {
    this.loading(false);
    this.mu.ui.notification(`<span uk-icon="icon: check"></span> ${message}`, {
      status: 'success',
      pos: 'top-left',
    });
  }

  error(data) {
    this.loading(false).extend('error', data);
  }

  submitAuth(form, e) {
    // console.log('SUBMIT AUTH', this.context._id);
    this.loading(true);
    const fields = form.getData();
    const { username, password } = fields;
    this.mu.user.login(username, password)
      .then(u => this.success(`Welcome back ${u.firstName}!`))
      .catch(() => this.error({ auth: 'Invalid Credentials' }));
  }

  submitReg(form, e) {
    this.loading(true);
    const fields = form.getData();
    this.mu.user.register(fields)
      .then(() => this.success(`Welcome ${fields.firstName}`))
      .catch(() => this.error({ reg: `Unable to register username: ${fields.username}` }));
  }

}

export class UserAddress extends MuMx.compose(null, [UserViewMixin, null, 'userAddress.html']) {

  onInit() {
    this.subscribeOne(UserAddress, this.view, () => this.mu.user.address()) // fire GET address when attached
      .subscribe('user.address', this.mu.user, this._dataUpdate.bind(this, 'address')) // subscribe to address changes
      .subscribe('addressForm', this.context, f => f && // when form attaches
        f.on('submit', this.save.bind(this))
      );
  }

  onMount() {
    this.editMode = this._ctxAttrBool('editing');
    this.context.extend({
      // state
      error: null,
      loading: false,
      editing: this.editMode,
      addressType: this._ctxProp('type') || 'home',
      legend: this._ctxProp('legend'),
      // actions
      actions: {
        edit: this.edit.bind(this),
        delete: this.delete.bind(this),
      }
    });
    
    super.onMount();
  }

  edit() {
    this.context.set('editing', true);
  }

  delete() {
    this.loading(true);
    const address = this.context.get('address');
    this.mu.user.deleteAddress(address)
      .then(() => this.done())
      .catch(() => this.loading(false));
  }

  save(form) {
    const address = form.getData();
    this.loading(true);
    return this.mu.user.saveAddress(address)
      .then(a => this.done(null, a))
      .catch(e => this.done(e, address));
  }

  done(error, address) {
    this.render({
      error,
      address,
      loading: false,
      success: !error,
      editing: !!error || this.editMode,
    });

    setTimeout(() => this.context.delete('success'), 1e3);
  }
}


export class UserPayment extends MuMx.compose(null,
  [UserViewMixin, null, 'userPayment.html']
) {
  
  onInit() {
    this.subscribeOne(UserPayment, this.view, () => this.mu.user.card()) // trigger card into
      .subscribe('user.card', this.mu.user, this._dataUpdate.bind(this, 'card')) // subscribe user payment
      .subscribe('paymentForm', this.context, f => f && f.on('submit', this.save.bind(this))); // when form attaches
  }

  onMount() {
    this.editMode = this._ctxAttrBool('editing');
    this.context.extend({
      // state
      error: null,
      loading: false,
      editing: this.editMode,
      legend: this._ctxProp('legend'),
      // actions
      actions: {
        edit: this.edit.bind(this),
        delete: this.delete.bind(this),
      }
    });
    
    super.onMount();
  }

  edit() {
    this._toggleEdit = true;
    this.render({ editing: true });
  }

  delete() {
    this.loading(true);
    const card = this.context.get('card');
    this.mu.user.deleteCard(card)
      .then(() => this.done())
      .catch(() => this.loading(false));
  }

  save(form) {
    const card = form.getData();
    this.loading(true)
    return this.mu.user.saveCard(card)
      .then(a => this.done(null, a))
      .catch(e => this.done(e, card));
  }

  done(error, card) {
    this.render({
      error,
      card,
      loading: false,
      success: !error,
      editing: !!error || this.editMode,
    });

    setTimeout(() => this.context.delete('success'), 1e3);
  }
}

export class CustomerAccount extends MuMx.compose(null, UserViewMixin) {

  onInit() {
    this.pageLoad = this.pageLoad.bind(this);
    this.subscribeOne('customer', this.mu.page, this.pageLoad)
  }
  onMount() {
    super.onMount();
  }

  pageLoad() {
    const { router, http } = this.mu;
    const { id } = router.queryparams() || { };
    this.render({ loading: true })
      .then(() => http.get(`/customers${id ? `/${id}` : ''}`))
      .then(res => {
        const data = res.data;
        const result = [].concat(res.data._embedded ? res.data._embedded.customer : res.data);
        return this.render({
          data,
          mock: data.mock,
          result,
          loading: false,
        });
      })
      .catch(error => this.render({ error, loading: false }));
  }

}

export class UserConsent extends MuMx.compose(null, ViewTemplateMixin) {

  onMount() {
    super.onMount();
    if (!this.consented()) {
      console.log('alskdjf');
      this.render({
        consent: this.accept.bind(this),
      });
    }
  }

  consented(consent) {
    const local = getGlobal('localStorage');
    if (local) {
      if (null == consent) {
        // get
        return !!local.getItem(USER_MU.CONSENT);
      } else {
        // set
        local.setItem(USER_MU.CONSENT, consent);
        return this;
      }
    }
  }

  dismiss() {
    // dismiss
    const { ui: { kit } } = this.mu;
    kit.alert(this.node).close();

    const { parentNode } = this.node;
    return parentNode && parentNode.removeChild(this.node);
  }

  accept() {
    this.consented(true);
    this.dismiss();
  }

}

export default Mu.macro(MUSHOP.MACRO.USER, UserController)
  .micro(UserView, attrToSelector(USER_MU.VIEW))
  .micro(UserAddress, attrToSelector(USER_MU.ADDRESS))
  .micro(UserPayment, attrToSelector(USER_MU.PAYMENT))
  .micro(UserToolbar, attrToSelector(USER_MU.TOOLBAR))
  .micro(UserConsent, attrToSelector(USER_MU.CONSENT))
  .micro(CustomerAccount, attrToSelector(USER_MU.CUSTOMER));
