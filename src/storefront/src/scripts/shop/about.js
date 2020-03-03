/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

import { Mu, MuMx, MuCtxAttrMixin } from '../mu';

import { ViewTemplateMixin } from './helper/viewmx';
import { Services, ServiceType, ServiceLinks, BasicServiceLinks, TechType } from './helper/info';

const toArray = obj => Object.keys(obj).map(k => obj[k]);
const createIds = arr => arr.forEach((row, id) => (row.id = id));
const nodeMax = (list, prop) => list.reduce((last, item) => Math.max(last, item[prop]), 0);
const toSymbol = icon => icon ? `image://${icon}` : 'circle';

const [SYMBOL_SVC, SYMBOL_TECH] = [40, 80];
const [AXIS_TOP, AXIS_LEFT] = [65, 55];

// create ids
createIds(toArray(ServiceType));
createIds(toArray(TechType));
createIds(toArray(Services));

export class MuServiceChart extends MuMx.compose(null, ViewTemplateMixin) {

  onMount() {
    super.onMount();
    const { router, config } = this.mu;
    const { basic, full } = router.queryparams() || {};
    config.get()
      .then(c => this.render({
        basic: basic || (!full && !!Object.keys(c.mockMode || {}).filter(s => c.mockMode[s]).length),
        initChart: this.handleChart.bind(this),
      }))
      .then(() => this.setOptions());
  }

  isBasic() {
    return this.context.get('basic');
  }

  offsetTop() {
    return ~~this._ctxProp('offset-top');
  }

  chartData() {

    // const gridDim = 10 + SYMBOL_SVC;

    const col = n => n;
    const row = n => n;
    const setCord = (svc, x, y, ...rest) => Object.assign(svc, { x, y }, ...rest);

    const isBasic = this.isBasic();
    const skew = {
      go: { label: { offset: [0, -20] }},
      java: { label: { offset: [0, -5] }},
    }

    // determine layout
    const data = { ...Services };
    if (isBasic) {
      // basic coordinates
      setCord(data.LB, col(0), row(0.5));
      
      setCord(data.API, col(1), row(0.25));
      setCord(data.STORE, col(1), row(0.75));
      setCord(data.CATALOG, col(2), row(0.25));

      setCord(data.ATP, col(2.9), row(.25));
      setCord(data.BUCKET, col(3), row(1));
    } else {
      // full system coordinates
      setCord(data.DNS, col(1), row(0.05));
      setCord(data.WAF, col(2), row(0.05));
      setCord(data.LB, col(3), row(0.05));

      setCord(data.BUCKET, col(4.5), row(0));
      setCord(data.STREAMING, col(5.5), row(0), { label: { offset: [0, 10] }});
      setCord(data.ATP, col(7.5), row(0));

      setCord(data.INGRESS, col(1), row(1));
      setCord(data.EDGE_ROUTER, col(1.5), row(2));

      setCord(data.STORE, col(2), row(2.5));
      setCord(data.ASSETS, col(2), row(1.5));
      setCord(data.API, col(2.5), row(2));

      setCord(data.EVENTS, col(3.5), row(1), skew.go);
      setCord(data.SESSION, col(3.5), row(3));

      setCord(data.CATALOG, col(5), row(2), skew.go);
      setCord(data.CART, col(5), row(3), skew.java);

      setCord(data.ORDERS, col(6), row(2), skew.java);
      setCord(data.NATS, col(7), row(2));
      setCord(data.FULFILLMENT, col(7), row(1));

      setCord(data.APIGW, col(6.5), row(0));
      setCord(data.SUBSCRIBE, col(8), row(1));
      setCord(data.EMAIL, col(8), row(2));

      setCord(data.PAYMENT, col(7), row(3), skew.go);
      setCord(data.USER, col(5), row(1));
    }

    const nodes = toArray(data)
      .filter(node => isBasic ? node.basic : true);

    createIds(nodes);
    nodes.forEach(node => {
      node.symbol = node.symbol || toSymbol(node.icon || node.type.icon);
      node.symbolSize = SYMBOL_SVC * (node.type.scale || 1);
    });
    return nodes;
  }

  serviceSeries(data, links, categories) {
    // positioning adjustments
    const topAxis = (this.offsetTop() + AXIS_TOP) * (this.isBasic() ? 2 : 1);
    return {
      data,
      links,
      categories,
      type: 'graph',
      layout: 'none',
      top: topAxis ,
      left: AXIS_LEFT,
      right: AXIS_LEFT,
      // bottom: AXIS_BOTTOM,
      roam: false,
      focusNodeAdjacency: true,
      itemStyle: {
        normal: {
          borderColor: '#ddd',
          borderWidth: 1,
          // shadowBlur: 10,
          shadowColor: 'rgba(0, 0, 0, 0.2)'
        }
      },
      symbolKeepAspect: true,
      edgeSymbol: ['none', 'circle'],
      edgeSymbolSize: [10, 10],
      label: {
        show: true,
        fontSize: 16,
        color: '#333',
        // backgroundColor: '#fff',
        backgroundColor: 'rgba(255, 255, 255, 0.5)',
        position: 'bottom',
        formatter: '{b}',
      },
      lineStyle: {
        color: 'target',
        opacity: 0.3,
        curveness: 0.2,
        width: 2,
      },
      emphasis: {
        lineStyle: {
          opacity: 1,
          width: 4,
        }
      }
    };
  }

  techSeries(services) {
    const techs = toArray(TechType).map(tech => {
      const nodes = services.filter(s => s.tech.id === tech.id);
      return {
        name: tech.name,
        symbol: tech.symbol || toSymbol(tech.icon),
        value: [
          0,
          nodeMax(nodes, 'x'),
          nodeMax(nodes, 'y'),
          nodes.length,
          tech.name,
        ]
      }
    });

    return {
      type: 'custom',
      data: techs,
      left: 0,
      symbolSize: SYMBOL_TECH,
      symbolKeepAspect: true,
      renderItem: this.renderTechBox.bind(this),
      encode: {
        x: [0, 1],
        y: 2,
        itemName: 4,
      },
      label: {
        normal: {
          show: true,
          position: 'insideTopLeft',
        }
      }
    };
  }

  renderTechBox(params, api) {
    const style = api.style();
    // console.log('HERE', params, style);
    const orig = api.coord([ api.value(0), api.value(2) ]);
    const size = api.size([ api.value(1) - api.value(0), api.value(2)]);
    // console.log(orig, size);
    return {
      style,
      type: 'rect',
      shape: {
        x: orig[0],
        y: orig[1],
        width: size[0],
        height: size[1],
      }
    }
  }

  chartOptions(data, links, categories) {
    return {
      tooltip: {
        formatter: p => p.dataType === 'node' ? 
          (p.data.tech.name + ': ' + (p.data.type.name !== p.name ? `${p.name} (${p.data.type.name})` : p.name)) : '',
      },
      legend: [{
        top: 0,
        left: 15,
        // orient: 'ho',
        data: categories.map(c => c.name),
      }],
      animationDuration: 1500,
      animationEasingUpdate: 'quinticInOut',
      textStyle: {
        fontFamily: 'Quicksand, sans-serif',
      },
      series: [
        this.serviceSeries(data, links, categories),
      ],
    };
  }

  setOptions() {
    const isBasic = this.isBasic();

    const data = this.chartData();
    const techs = data.map(d => isBasic ? d.basic.id : d.tech.id);
    // collect relevant categories
    const categories = toArray(TechType)
      .filter(t => techs.indexOf(t.id) > -1)
      .map(c => ({
        ...c,
        itemStyle: {
          color: c.color || null
        }
      }));
    // re-index
    createIds(categories);
    const cats = categories.map(c => c.name);
    // assign nodes to categories
    data.forEach(node => {
      const tech = (isBasic ? node.basic : node.tech);
      node.category = cats.indexOf(tech.name);
      node.techref = tech;
    });

    // determine links
    const links = (isBasic ? BasicServiceLinks : ServiceLinks)
      .filter(l => l.source && l.target)
      .map(({source, target, ...rest}) => ({source: source.id, target: target.id, ...rest}));

    const options = this.chartOptions(data, links, categories);
    this.context.set('services', {
      list: data,
      chart: options,
    });

  }

  handleChart(chart) {
    chart.on('legendselectchanged', params => {
      const { selected } = params;
      this.context.set('hide', {
        oci: !selected[TechType.OCI.name],
        oke: !selected[TechType.OKE.name],
        edge: !selected[TechType.EDGE.name],
        compute: !selected[TechType.COMPUTE.name],
      });
    });
  }

}

export class MuTechBox extends MuMx.compose(null, ViewTemplateMixin, MuCtxAttrMixin) {
  onMount() {
    super.onMount();
    const prop = this._ctxProp('mu-tech-box');
    const tech = TechType[prop] || prop;
    this.render({ tech });
  }
}

export default Mu
  .micro(MuServiceChart, '[mu-service-chart]')
  .micro(MuTechBox, '[mu-tech-box]');