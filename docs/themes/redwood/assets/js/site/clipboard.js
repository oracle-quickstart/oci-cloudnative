/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
;(function(w, d) {
  'use strict';

  function isWin() {
    return navigator && /windows/i.test(navigator.userAgent || '');
  }

  function clipboard(link) {
    var text = this.innerText.trim();
    if (isWin()) { // strip breaks
      text = text.replace(/\s\\\s*\n\s*/g, ' ');
    }
    var area = d.createElement('textarea');
    area.textContent = text;
    area.style.height = area.style.width = 0;
    d.body.appendChild(area);
    area.select();
    d.execCommand("copy");
    d.body.removeChild(area);
    link.innerHTML = '<span uk-icon="check" class="uk-animation-slide-right-small"></span>';
    setTimeout(function() { link.innerHTML = link._icon; }, 2000);
    return false;
  }

  // initialize snippets with copy
  var nodes = d.querySelectorAll('pre > code');
  var iter = Array.apply(null, nodes);
  for (var i=0; i < iter.length; i++) {
    var code = iter[i];
    var copy = document.createElement('a');
    copy.innerHTML = copy._icon = '<span uk-icon="copy" class="uk-animation-fast uk-animation-fade"></span>';
    copy.setAttribute('title', 'Copy');
    copy.classList = 'copier';
    copy.addEventListener('click', clipboard.bind(code, copy));
    code.parentNode.appendChild(copy);
  }
})(window, document);