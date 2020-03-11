/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
;(function(win, doc) {
  var store = win.localStorage || { setItem: function(){}, getItem: function(){} };
  
  function applySetting(node, buttons, value) {
    var setting = node.getAttribute('setting');
    var selector = node.getAttribute('target');
    var key = 'rw-' + setting;
    var delim = /[\s,]+/;

    var alltoggles = [];
    buttons.forEach(function(button) {
      var toggle = button.getAttribute('toggle') || '';
      alltoggles.push.apply(alltoggles, toggle.split(delim));
      button.classList[value === toggle ? 'add' : 'remove']('uk-active');
    });

    Array.apply(null, doc.querySelectorAll(selector)).forEach(function(target) {
      alltoggles.forEach(function(t) {
        t && target.classList.remove(t);
      });
      value && target.classList.add.apply(target.classList, value.split(delim));
    });
    store.setItem(key, value);
  }

  var groups = doc.querySelectorAll('#rw-settings .rw-setting');
  Array.apply(null, groups).forEach(function(node) {
    var setting = node.getAttribute('setting');
    var key = 'rw-' + setting;
    var value = store.getItem(key) || null;

    var buttons = Array.apply(null, node.querySelectorAll('button'));
    buttons.forEach(function(button) {
      var toggle = button.getAttribute('toggle') || '';
      if (value === null) {
        value = button.classList.contains('uk-active') ? toggle : null;
      }
      button.addEventListener('click', applySetting.bind(null, node, buttons, toggle));
    });

    applySetting(node, buttons, value);
  });

})(window, document);