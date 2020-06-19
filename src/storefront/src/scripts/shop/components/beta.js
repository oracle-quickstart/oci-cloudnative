/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

import { Mu, MuMx, MuCtxSingleAttrMixin, attrToSelector } from '../../mu';

const BETA_BANNER_ATTR = 'mu-beta-banner';

export class MuBetaBanner {

  onMount() {
    this.render();
  }

  render() {
    const ver = this.mu.root.context.get('VERSION');
    return /beta/i.test(ver) && this.view.render(this.node, `
      <div uk-alert class="uk-alert-warning">
        <p>You are viewing a beta version of MuShop: <span class="uk-text-bold">v{{ver}}</span>
        <br>
        Features enabled on this version are :</a><br>
        <a href="reviews.html" mu-route>Review</a>
        </p>  
      </div>`,
      { ver },
    );
  }
}

export default Mu.micro(MuBetaBanner, attrToSelector(BETA_BANNER_ATTR));
