//= require ../lib/_jquery

/**
Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
*/
;(function (w) {
  'use strict';

  var toggles = {};

  function initToggle() {
    var key = $(this).data('toggle-name');
    $(this).find('a').attr('toggle-key', key).click(function() {
      applySetting(key, $(this).data('toggle'));
      return false;
    });
    toggles[key] = $(this);
    getSetting(key);
  }

  function applySetting(key, value) {
    // adjust active
    var a = toggles[key].find('[data-toggle]');
    a.each(function() {
      var val = $(this).data('toggle');
      var c = $('[class*="' + val + '"]');
      if (val === value) {
        $(this).addClass('active');
        c.show();
      } else {
        $(this).removeClass('active');
        c.not('[class*="' + value + '"]').hide();
      }
    });
    
    // keep preference
    try {
      w.localStorage.setItem(key, value);
    } catch (e) {}

    // reset TOC heights
    return ('recacheHeights' in w && w.recacheHeights());
  }

  function getSetting(key) {
    var value = toggles[key].find('a:first').data('toggle');
    try {
      value = w.localStorage.getItem(key) || value;
    } catch (e) {}
    applySetting(key, value);
  }

  // initialize the settings
  $(function() {
    $('.toggle-group').each(initToggle);
  });

})(window);
