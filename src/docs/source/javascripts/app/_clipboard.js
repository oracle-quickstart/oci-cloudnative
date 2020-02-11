/**
Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
*/
;(function (d) {
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
    return false;
  }

  // initialize snippets with copy
  d.addEventListener("DOMContentLoaded", function() {
    var nodes = d.querySelectorAll('pre > code');
    var iter = Array.apply(null, nodes);
    for (var i=0; i < iter.length; i++) {
      var code = iter[i];
      var copy = document.createElement('a');
      copy.innerHTML = '<span></span><span></span>';
      copy.setAttribute('title', 'Copy');
      copy.classList = 'copier';
      copy.addEventListener('click', clipboard.bind(code, copy));
      code.parentNode.appendChild(copy);
    }
  });
})(document);
