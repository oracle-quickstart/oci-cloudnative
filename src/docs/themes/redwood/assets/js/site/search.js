/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
;(function(win, doc) {

  var _lunrIdx;
  function getLunrIdx(cb) {
    var idx = win.Site.RelURL + '/index.json';
    return _lunrIdx ? cb(_lunrIdx) : fetch(idx).then(function(response) {
        return response.ok ? response.json() : [];
      }).then(function(pages) {
        var idx = lunr(function() {
          this.ref('uri');
          this.field('title', { boost: 0 });
          this.field('description', { boost: 10 });
          this.field('tags', { boost: 10 });
          this.field('content', { boost: 5 });
          return pages.forEach(function(page) {
            this.add(page);
          }, this);
        });
        _lunrIdx = { pages: pages, lunr: idx };
        cb(_lunrIdx);
      });
  }

  function highlight(text, term) {
    var wds = '(?:\\s?(?:[\\w]+)\\s?){0,3}'
    var chunk = text.match(new RegExp(wds + term + wds, 'i'));
    if (chunk) {
      return chunk[0]
        .replace(new RegExp('('+term+')', 'ig'), '<span class="highlight">$1</span>');
    }
    return text;

  }

  // init autocomplete
  autocomplete('#search', {
    hint: false,
    clearOnSelected: true,
    appendTo: '#search-results',
    cssClasses: {
      root: 'uk-height-medium uk-position-relative uk-overflow-auto uk-padding-small',
      dropdownMenu: 'rw-search-dropdown',
      noPrefix: true,
      suggestion: 'suggestion uk-text-truncate force-nowrap uk-margin-small rw-accent-orange',
      empty: 'uk-background-muted',
    }
  }, [{
    source: function(q, cb) {
      getLunrIdx(function(idx) {
        var suggs = idx.lunr
          .search(q+'^100 '+q+'*^10 *'+q+'^10 '+q+'~2^1')
          // .search(q+'^100')
          .map(function(result) {
            var page = idx.pages.reduce(function(p, page) {
              return p || (page.uri === result.ref && page);
            }, null);
            return {
              term: q,
              result: result,
              page: page,
            };
          });

        cb(suggs);
      });
    },
    templates: {
      suggestion: function(sugg) {
        var term = sugg.term;
        var page = sugg.page;
        // matched title
        const isTop = page.title.toLowerCase().indexOf(page.section.toLowerCase()) > -1;
        var section = highlight(page.section, term)
        var title = highlight(page.title, term);
        var content = highlight(page.content, term);
        // // matched tags
        // var tags = sugg.page.tags.filter(function(tag) {
        //   return tx.test(tag);
        // });
        var items = [!isTop && section, title]
          .filter(function(i){ return !!i})
          .map(function(i) {
            return `<span class="uk-text-capitalize">` + i + '</span>';
          });
        var a = document.createElement('a');
        a.href = page.uri;
        a.innerHTML = items.join('<span uk-icon="chevron-double-right"></span>')
          .concat('<div class="uk-text-muted uk-text-truncate">' + content + '</div>');
        return a.outerHTML;
      }
    }
  }]).on('autocomplete:selected', function(e, sugg) {
    console.log('ac:selected');
  });
  
  
})(window, document);