/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

import { Mu, MuMx } from '../../mu';
import { MuCtxSetterMixin, MxCtxAttrRefresh } from '../../mu/bindings';
import { ShopMxSubscriber } from '../helper/subscriber';
import { getGlobal, getWindow } from '../../util/window';
import { ECHARTS_GLOBAL } from '../../util/constants';
import { Wait } from '../../util/wait';

export const ChartConfig = {
  THEME: 'MUTHEME',
  // keys
  OPTIONS: 'options',
}

export class MuChart extends MuMx.compose(null, [MxCtxAttrRefresh, ChartConfig.OPTIONS]) {
    
  constructor(w) {
    super();
    this.w = w;
    this.lib = this.lib.bind(this);
    this.resize = this.resize.bind(this);
  }

  onMount() {
    this.w.addEventListener('resize', this.resize);
    this.registerTheme().then(lib => {
      this.main = lib;
      this.chart = lib.init(this.node, ChartConfig.THEME, {
        // renderer: 'svg'
      });
      const cb = this._ctxAttrValue('onInit');
      super.onMount();
      return cb && cb(this.chart);
    });
  }

  onDispose() {
    super.onDispose();
    this.w.removeEventListener('resize', this.resize);
    const { chart, main } = this;
    return main && main.dispose(chart);
  }

  /**
   * resolve async echarts global
   */
  lib() {
    const echarts = getGlobal(ECHARTS_GLOBAL);
    return Promise.resolve(echarts || Wait(100).then(this.lib));
  }

  resize() {
    return this.chart && this.chart.resize();
  }

  registerTheme() {
    return this.lib().then(lib => { 
      lib.registerTheme(ChartConfig.THEME, {
        backgroundColor: 'transparent',
      });
      return lib;
    });
  }

  refresh(options) {
    // console.log('CHART refresh', this.context._id, this._ctxKey(), options);
    if (options) {
      this.chart = this.chart || this.main.init(this.node, ChartConfig.THEME, options);
      this.chart.setOption(options);
    }
  }
}

export default Mu.micro(MuChart, '[mu-chart]', getWindow());
