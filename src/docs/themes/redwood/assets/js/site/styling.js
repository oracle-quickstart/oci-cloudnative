/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
;(function(w, d) {

  function iterHash(hash, cb) {
    return hash && Object.keys(hash)
      .forEach(function(key) {
        cb(key, hash[key]);
      });
  }

  function iterSelector(selector, cb) {
    Array.apply(null, d.querySelectorAll(selector))
      .forEach(cb);
  }

  // decorate hugo defaults with CSS classes
  iterHash(w.Site.cssConfig, function(selector, cls) {
    cls = cls.split(/[\s,]+/);
    iterSelector(selector, function(el) {
      el.classList.add.apply(el.classList, cls);
    });
  });

  // apply uikit to hugo defaults
  iterHash(w.Site.uikit, function(selector, def) {
    var component = def[0];
    var opts = def.slice(1);
    var kit = UIkit[component];
    return kit && iterSelector(selector, function(el) {
      kit.apply(UIkit, [el].concat(opts));
    });
  });
  
})(window, document);