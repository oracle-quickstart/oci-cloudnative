/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

import 'core-js/features/url';
import 'core-js/features/url-search-params';

import { Mu, MuMx } from '../mu';
import { getWindow } from '../util/window';
import { MUSHOP } from './constants';
import { ViewTemplateMixin } from './helper/viewmx';

/**
 * Router macro
 */
export class MuRouterMacro {
  constructor(w) {
    this._routes = {};
    this._state = null;
    this.history = w.history || {};
    this.location = w.location || {};

    // handle back nav
    w.addEventListener('popstate', e => {
      const state = e.state;
      if (state) {
        this._state = state;
        this.emit('back', state);
      }
    });

    // state fallback
    ['pushState', 'replaceState'].forEach((prop) => {
      this.history[prop] = this.history[prop] || ((s, t, r) => {
        this.set(r);
      });
    });
  }

  _push(url, state, title) {
    this._state = state;
    this.history.pushState(state, title, url);
  }

  _replace(url, state, title) {
    this._state = state;
    this.history.replaceState(state, title, url);
  }

  state() {
    return this._state;
  }

  search() {
    return this.location.search;
  }

  pathname() {
    return this.location.pathname;
  }

  querystring(q) {
    var query = new URLSearchParams();
    Object.keys(q).forEach(p => query.set(p, q[p]));
    return query.toString();
  }

  queryparams(q) {
    q = (q || this.search()).split('?').slice(1).join('?');
    if (q) {
      var query = new URLSearchParams(q);
      var search = {};
      query.forEach((val, key) => search[key] = val);
      return search;
    }
  }

  /**
   * register routes
   * @param {string} name 
   * @param {string} path 
   * @param {string|RegExp|(string|RegExp)[]} alias 
   */
  register(name, path, alias) {
    this._routes[name] = {
      path: path,
      paths: [path].concat(alias || [])
    };
    return this;
  }

  /**
   * set the router location
   * @param {string} href 
   */
  set(href) {
    if (this.location.href !== href) {
      this.location = href;
    }
  }

  href(name, search) {
    const route = this._routes[name];
    const qs = search ? '?' + this.querystring(search) : '';
    return route.path + qs;
  }

  is(name) {
    return name === this.resolve();
  }

  /**
   * make router/state reflect the params
   */
  go(name, search, params, replace) {
    const route = this._routes[name];
    const href = this.href(name, search);
    const call = replace ? '_replace' : '_push';
    this[call](href, {
      name: name,
      route: route,
      search: search,
      params: params
    });
    this.emit('update', name, search, params, replace);
    return this;
  }

  /**
   * resolve the initial state
   */
  initial(fallback) {
    const name = this.resolve() || fallback;
    const route = this._routes[name];
    const search = this.queryparams(this.search());
    this._replace(null, {
      name: name,
      route: route,
      search: search
    });
    // console.log(typeof this.emit, typeof this.on);
    // this.emit('initial', name);
    return name;
  }

  /**
   * resolve the registered route name from the pathname
   */
  resolve(path) {
    path = path || this.pathname();
    var routes = this._routes;
    var route = Object.keys(routes).reduce(function(p, name) {
      return p || (routes[name].paths.reduce(function(m, rule) {
        rule = rule instanceof RegExp ? rule : new RegExp(`^\\/?${rule}`);
        return m || rule.test(path);
      }, false) && name);
    }, null);
    return route;
  }
}

/**
 * Mu Route micro binding
 */
export class MuRouteLink {

  constructor() {
    this.click = this.click.bind(this);
  }

  onMount() {
    this.node.addEventListener('click', this.click);
  }
  onDispose() {
    this.node.removeEventListener('click', this.click);
  }

  click(e) {
    e.preventDefault();
    e.stopPropagation();
    const { router } = this.mu;
    var href = this.node.getAttribute('mu-route-href') || this.node.getAttribute('href') || '';
    var page = router.resolve(href);
    if (page) {
      var query = router.queryparams(href);
      router.go(page, query);
    } else {
      console.log('unresolved route', href);
      router.set(href);
    }
    return false;
  }
}

export class MuRouteProps extends MuMx.compose(null, ViewTemplateMixin) {
  onMount() {
    const { router } = this.mu;
    super.onMount();
    this.render({
      query: router.queryparams(),
      state: router.state(),
    });
  }
}

export default Mu.macro(MUSHOP.MACRO.ROUTER, MuRouterMacro, getWindow())
  .micro(MuRouteLink, '[mu-route],.mu-route')
  .micro(MuRouteProps, '[mu-route-props]');