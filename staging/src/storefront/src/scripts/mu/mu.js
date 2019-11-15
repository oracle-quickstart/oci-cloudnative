/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

import 'core-js/features/map';
import 'core-js/features/set';
import axios from 'axios';
import { attrToSelector } from './util';

const MuUtil = {

  randId: () => Math.random().toString(36).replace(/[^a-z]+/g, '').substr(0, 5),

  /**
   * resolve path to its tree
   */
  propPath(path) {
    return (path || '').split(/[:.]/).filter(p => !!p);
  },

  propTarget(object, prop) {
    const path = this.propPath(prop);
    const key = path.pop();
    const target = path.reduce((last, key) => (last[key] = last[key] || {}), object);
    return { target, key };
  },

  /**
   * define property on object
   * @param {*} object
   * @param {*} prop 
   * @param {*} value 
   */
  defineProp(object, prop, value) {
    const { target, key } = this.propTarget(object, prop);
    Object.assign(target, key ? { [key]: value } : value);
  },

  deleteProp(object, prop) {
    const { target, key } = this.propTarget(object, prop);
    delete target[key];
  },

  mergeProp(object, prop, mixin) {
    this.defineProp(object, prop, mixin);
  },

  /**
   * resolve an object propery by path
   * @param {*} object 
   * @param {*} path 
   */
  resolveProp(object, path) {
    return this.propPath(path)
      .reduce((last, k) => {
        if (!!last && typeof last === 'object') {
          return last[k]
        }
      }, object);
  },

  /**
   * create module definitions for later instantiation
   * @param {Function} ctor - module constructor
   * @param {*} name - unique module name
   * @param {string} binding - module binding selector
   * @param  {...any} args - dependencies
   */
  defineModule(ctor, name, binding, ...args) {
    const mod = { ctor, name, binding, args };
    return mod;
  },

  /**
   * initialize a mu module
   * @param {*} mod - module definition
   * @param {Mu} mu - mu instance
   * @param {MuView} view - mu view
   * @param {MuContext} [context] - module context
   */
  initModule(mod, mu, view, context) {
    const emitter = new MuEmitter(mod.ctor.name);
    const ModCtor = MuMx.pure(mod.ctor, ...mod.args);
    const emits = ['on', 'one', 'always', 'off', 'emit', 'emitOnce'];
    MuUtil.mergeProp(ModCtor.prototype, null, {
      mu, 
      view,
      // context
      ...(context ? { context } : {}),
      // emitter methods
      ...Object.assign(...emits.map(m => ({[m]: emitter[m].bind(emitter)}))),
    });

    // instantiate
    const instance = new ModCtor();
    // call lifecycle hook
    instance.onInit && instance.onInit();

    return instance;
  },
}


export const MuMx = {
  /**
   * create a pure class by seeing the ctor's arguments
   * @param {function} superclass 
   * @param  {...any} superargs 
   */
  pure(superclass, ...superargs) {
    return this.mixin(superclass, ...superargs);
  },

  /**
   * mixin any class with supplied ctor args
   * @param {*} superclass 
   * @param  {...any} args 
   */
  mixin(superclass, ...superargs) {
    return class extends superclass {
      constructor(...rest) {
        super(...superargs.concat(rest));
      }
    };
  },
  
  /**
   * @TODO WIP!!
   * @param base - base class
   * @param  {...any} mixins 
   */
  compose(base, ...mixins) {
    base = base || class {};
    return mixins
      // normalize to [ctor, ...rest]
      .map(row => [].concat(row))
      // combine mixins into one
      .reduceRight((prev, args) => {
        const factory = args.shift();
        return factory(prev, ...args);
      }, base);
  }

};

export class MuLogger {
  constructor() {
    this.init();
  }

  init() {
    Object.assign(this, console);
  }
}

/**
 * 
 */
export class MuEmitter {

  constructor(name) {
    this._name = name;
    this._listeners = new Map();
    this._emits = new Map();
    this._id = MuUtil.randId();
    this._logger = new MuLogger();
  }

  on(hook, listener) {
    this._getSet(hook).add(listener);
    // this._emitLast(hook, listener);
    return this;
  }

  one(hook, listener) {
    // replace all listeners with this one
    this._getSet(hook).clear();
    return this.on(hook, listener);
  }

  always(hook, listener) {
    this.on(hook, listener)._emitLast(hook, listener);
    return this;
  }

  off(hook, listener) {
    this._getSet(hook).delete(listener);
    return this;
  }

  emit(hook, ...args) {
    this._emits.set(hook, args);
    this._getSet(hook).forEach(l => this._emitLast(hook, l));
    return this;
  }

  emitOnce(hook, ...args) {
    this._getSet(hook).forEach(l => l(...args));
    return this;
  }

  _getSet(hook) {
    let s = this._listeners.get(hook);
    if (!s) {
      s = new Set();
      this._listeners.set(hook, s);
    }
    return s;
  }

  _emitLast(hook, listener) {
    const args = this._emits.get(hook);
    if (args) {
      this._logger.log(`${this._name}::${hook}`);
      listener(...args);
    }
  }

  dispose() {
    this._emits.clear();
    this._listeners.clear();
  }
}

/**
 * 
 */
export class MuContext extends MuEmitter {

  static isContext(data) {
    return data && data instanceof MuContext;
  }

  static toContext(data) {
    return this.isContext(data) ? data : new MuContext(data);
  }

  constructor(ctx) {
    super('MuContext');
    this.data = MuContext.isContext(ctx) ? ctx.get() : { ...(ctx || {}) };
    this.set('ctxId', this._id);
  }

  /**
   * set the context value
   * @param {string} key 
   * @param {*} val 
   */
  set(key, val) {
    MuUtil.mergeProp(this.data, key, val);
    this.emit(key, this.get(key));
    if (val && typeof val === 'object') {
      // propagate to the child subscribers
      const pre = (key ? key + '.' : '');
      Object.keys(val)
        .map(k => pre + k)
        .forEach(k => this.emit(k, this.get(k)));
    }
    return this;
  }

  /**
   * get context value from key path
   * @param {string} key - path to resolve in the data
   */
  get(key) {
    return MuUtil.resolveProp(this.data, key);
  }

  /**
   * check if key is set in context
   * @param {string} key 
   */
  has(key) {
    return !!this.get(key);
  }

  /**
   * delete property
   * @param {*} key 
   */
  delete(key) {
    MuUtil.deleteProp(this.data, key);
    return this.emit(key);
  }

  /**
   * 
   * @param {string} key 
   * @param {function} cb 
   */
  always(key, cb) {
    cb(this.get(key));
    return this.on(key, cb);
  }

  /**
   * extend the root context with the new object
   * @param {object|string} prop 
   * @param {object} [data] 
   */
  extend(prop, data) {
    const field = data ? prop : null;
    const val = data ? data : prop;
    return this.set(field, val);
  }

  /**
   * Create a child context
   * @param {*} withData 
   */
  child(withData) {
    return MuContext.toContext({
      ...this.get(),
      ...(withData || {}),
      ctxParent: this,
    });
  }

  /**
   * resolve parent context
   */
  parent() {
    return this.get('ctxParent');
  }

}

const MUPROP = {
  MU: 'mu',
  MUS: 'mus',
  CTX: 'muctx',
  CLOAK: 'mu-cloak',
};

/**
 * Mu client rendering engine
 * @param {Mu} mu - Mu instance
 * @param {object} options - view options 
 * @param {string} options.basePath - base path for view loading
 * @param {object} options.micro - micro module definitions
 */
export class MuView extends MuEmitter {
  constructor(mu, options) {
    super('MuView');
    this.mu = mu;
    this.options = options;
    this.loader = axios.create();
    this._viewCache = new Map();
    this._templatePattern = /\{\{([\w.:]+)\}\}/; // TODO, make option
  }

  virtual(html, selector) {
    const parser = new DOMParser();
    const virtual = parser.parseFromString(html || '', 'text/html');
    return selector ? virtual.querySelector(selector) : virtual;
  }

  virtualContainer() {
    return this.virtual('<div></div>', 'div');
  }

  load(path) {
    const c = this._viewCache.get(path);
    const p = Promise.resolve(c || this.loader.get(path).then(res => res.data))
    if (!c) {
      this._viewCache.set(path, p);
    }
    return p;
  }

  loadView(view) {
    const { basePath } = this.options;
    var path = (basePath || '') + '/' + view;
    return this.load(path);
  }

  renderRemote(target, view, context) {
    return this.loadView(view)
      .then(template => this.render(target, template, context));
  }

  render(target, template, context) {
    const output = this.interpolate(template, context);
    // this.emit('rendered', target, data);
    return Promise.resolve(this.apply(target, output, context));
  }

  interpolate(template, context) {
    const pattern = this._templatePattern;
    const regGlobal = new RegExp(pattern, 'g');
    const renderCtx = MuContext.toContext(context);
    const raw = template || '';
    return Array.apply(null, raw.match(regGlobal) || [])
      .reduce((out, ph) => {
        const prop = ph.replace(pattern, '$1');
        return out.replace(ph, renderCtx.get(prop) || '');
      }, raw);
  }

  apply(target, html, context) {
    this.dispose(target);
    target.innerHTML = html;
    return this.attach(target, context);
    // const virtual = this.virtual(`<div>${html}</div>`, 'div');
    // const bound = this.attach(virtual, context);
    // target.innerHTML = '';
    // Array.apply(null, bound.children)
    //   .forEach(node => target.appendChild(node));
  }

  attach(target, context) {
    const { micro } = this.options;
    const commonCtx = context && MuContext.toContext(context);
    const _mus = [];

    // bind mu to the anything with standard [mu] selector
    Array.apply(null, target.querySelectorAll(attrToSelector(MUPROP.MU)))
      .forEach(node => MuUtil.mergeProp(node, null, {
        [MUPROP.MU]: this.mu, // direct access to mu
        [MUPROP.CTX]: this.mu.root.context, // global context
      }));

    // keep mus array on target
    MuUtil.defineProp(target, MUPROP.MUS, _mus);

    const addPrebindings = parent => {
      const any = micro.map(mod => mod.binding).join(',');
      Array.apply(null, parent.querySelectorAll(any))
        .filter(c => !c.muOriginal)
        .forEach(child => {
          const clone = child.cloneNode(true);
          MuUtil.defineProp(child, 'muOriginal', () => 
            addPrebindings(clone.cloneNode(true)));
        });

      return parent;
    };

    // assign getters on prebound objects
    addPrebindings(target);
    
    // bind micros
    micro.forEach(mod => {
      const nodes = target.querySelectorAll(mod.binding);
      const list = [];
      // instantiate per node
      Array.apply(null, nodes).forEach(node => {
        // determine context
        const nodeCtx = MuUtil.resolveProp(node, MUPROP.CTX);
        const ctx = nodeCtx || commonCtx || 
          (!mod.ctor.CTX_INHERIT_ONLY && MuContext.toContext()); // context may be shared or uniquely scoped
        
        if (ctx && target.contains(node)) {
          const instance = MuUtil.initModule(mod, this.mu, this, ctx);
          MuUtil.defineProp(instance, 'node', node); // assign the node to the instance
          // MuUtil.defineProp(node, MUPROP.CTX, ctx); // assign sticky context to the node for persistence
          // reference the instance in the target's mus
          _mus.push(instance);
          list.push(node);
          return instance.onMount && instance.onMount();
        }

      });

      if (list.length) {
        this.emitOnce(mod.ctor, target, list);
      }

    });

    // remove cloak
    target.removeAttribute(MUPROP.CLOAK);

    // emit that view was attached
    this.emitOnce('attached', target);
    return target;
  }

  dispose(target, andContext) {
    const _mus = MuUtil.resolveProp(target, MUPROP.MUS);
    const { context: rootCtx } = this.mu.root;
    if (_mus) {
      let m;
      while (m = _mus.shift()) {
        m.emit('dispose').dispose();  // dispose emitter
        m.onDispose && m.onDispose(); // dispose hook
        if (andContext && m.context !== rootCtx) { // dispose (non-root) context
          m.context.dispose();
        }
      }
    }
    return target;
  }
}

/**
 * Main Mu application 
 */
export class Mu extends MuEmitter {
  
  constructor() {
    super('Mu');
  }

  /**
   * reset Mu
   */
  static clean() {
    this._core = this._core || [];
    this._macro = []; // define static macro singleton modules on mu instance
    this._micro = []; // define static micro components for view bindings
    return this;
  }

  /**
   * register a component to the mu namespace (macro)
   * @param {string} name 
   * @param {Function} ctor 
   * @param  {...any} args 
   */
  static macro(name, ctor, ...args) {
    this._macro.push(MuUtil.defineModule(ctor, name, null, ...args));
    return this;
  }

  /**
   * register a view micro binding
   * @param {Function} ctor 
   * @param {string} selector 
   * @param  {...any} args 
   */
  static micro(ctor, selector, ...args) {
    this._micro.push(MuUtil.defineModule(ctor, null, selector, ...args));
    return this;
  }

  /**
   * Create core micros
   * @param {Function} ctor 
   * @param {string} selector 
   */
  static core(ctor, selector) {
    this._core.push(MuUtil.defineModule(ctor, null, selector));
    return this;
  }

  /**
   * Main Mu Start point
   * @param {HTMLElement} main 
   * @param {object} options
   * @param {string} options.root - root node selector
   * @param {string} options.baseViewUrl - base url for view loading
   * @param {*} options.context - global context
   */
  static run(main, options) {
    const { mu, view } = this.init(main, options);
    return this.start(mu, view);
  }

  /**
   * Main Mu instance Initializer
   * @param {HTMLElement} main 
   * @param {object} options
   * @param {string} options.root - root node selector
   * @param {string} options.baseViewUrl - base url for view loading
   * @param {*} options.context - global context
   */
  static init(main, options) {
    const mu = new Mu();
  
    // resolve options for this instance
    const opts = Object.assign({
      root: main.nodeName,
      baseViewUrl: '/views',
      context: {},
    }, options || {});
  
    // create singleton view engine with micro bindings
    const micro = [].concat(this._core, this._micro);
    const view = new MuView(mu, {
      micro,
      basePath: opts.baseViewUrl,
    });

    // create global context
    const context = new MuContext(options.context);

    // assign root object
    MuUtil.defineProp(mu, 'root', {
      context,
      element: main,
      selector: opts.root,
    });
  
    // init macros with global context
    this._macro.forEach(mod => {
      const instance = MuUtil.initModule(mod, mu, view, context);
      // assign to the mu instance (as macro)
      MuUtil.mergeProp(mu, mod.name, instance);
    });

    return { mu, view };
  }

  /**
   * helper for testing
   * @param {Mu} mu 
   * @param {MuView} view 
   */
  static start(mu, view) {
    // attach main node to view (without any default context)
    view.attach(mu.root.element, null);
    // emit ready
    mu.emit('ready');
    return mu;
  }

}

Mu.clean();
