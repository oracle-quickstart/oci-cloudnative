//= require ../lib/_jquery

/**
Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
*/
;(function () {
  'use strict';

  function addContributor(target, data) {
    var div = $('<div/>').addClass('flex');
    target.append(div);
    div.append($('<img/>').attr({
      src: data.avatar_url,
      alt: data.login,
    })).append($('<div/>')
      .append($('<a/>').attr({href: data.html_url, title: data.login }).text('@'+data.login))
      .append($('<div/>').text(data.contributions + ' contributions'))
    );
  }

  // initialize the collaborators view
  $(function() {
    var api = 'https://api.github.com/repos/oracle-quickstart/oci-cloudnative/contributors';
    $.getJSON(api, function(data) {
      return data && data.filter(row => row.type.toLowerCase() === 'user')
        .map(addContributor.bind(null, $('#muContributors')));
    });
  });
})();
