import { Mu, MuMx, MuCtxAttrMixin } from '../mu';

import { ViewTemplateMixin } from './helper/viewmx';
import { Services, ServiceType, ServiceLinks, TechType } from './helper/info';

const toArray = obj => Object.keys(obj).map(k => obj[k]);
const createIds = arr => arr.forEach((row, id) => (row.id = row.id || id));
const nodeMax = (list, prop) => list.reduce((last, item) => Math.max(last, item[prop]), 0);
const toSymbol = icon => icon ? `image://${icon}` : 'circle';

const [SYMBOL_SVC, SYMBOL_TECH] = [40, 80];
const [AXIS_TOP] = [40];

// create ids
createIds(toArray(ServiceType));
createIds(toArray(TechType));
createIds(toArray(Services));

export class MuServiceChart extends MuMx.compose(null, ViewTemplateMixin) {

  onMount() {
    super.onMount();
    this.render({
      initChart: this.handleChart.bind(this),
    }).then(() => this.setOptions());
  }

  chartData() {

    const gridDim = 10 + SYMBOL_SVC;

    const col = n => n * gridDim;
    const row = n => n * gridDim;

    const data = { ...Services };
    Object.assign(data.BUCKET, { x: col(4), y: row(0) });
    Object.assign(data.ATP, { x: col(5), y: row(0), label: { offset: [0, -20] }});
    Object.assign(data.STREAMING, { x: col(6), y: row(0), label: { offset: [0, 5] }});

    Object.assign(data.INGRESS, { x: col(1), y: row(2) });
    Object.assign(data.STORE, { x: col(3), y: row(1) });
    Object.assign(data.API, { x: col(3), y: row(2) });
    Object.assign(data.SESSION, { x: col(4), y: row(3) });

    Object.assign(data.CATALOG, { x: col(6), y: row(1) });
    Object.assign(data.ORDERS, { x: col(6), y: row(2) });
    Object.assign(data.CART, { x: col(6), y: row(3) });

    Object.assign(data.SHIPPING, { x: col(8), y: row(3) });
    Object.assign(data.STREAM, { x: col(8), y: row(2) });
    Object.assign(data.PAYMENT, { x: col(8), y: row(1) });

    Object.assign(data.USER, { x: col(4), y: row(2) });
    Object.assign(data.USERDB, { x: col(5), y: row(3) });

    const nodes = toArray(data);
    createIds(nodes);
    nodes.forEach(node => {
      // categorize services by type
      node.category = node.tech.id;
      node.symbol = node.symbol || toSymbol(node.icon || node.type.icon);
      node.symbolSize = SYMBOL_SVC * (node.type.scale || 1);
    })
    return nodes;
  }

  serviceSeries(data, links, categories) {
    return {
      data,
      links,
      categories,
      type: 'graph',
      layout: 'none',
      top: AXIS_TOP,
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
      edgeSymbol: ['none', 'arrow'],
      label: {
        show: true,
        fontSize: 16,
        fontFamily: 'Roboto, sans-serif',
        backgroundColor: '#fff',
        position: 'bottom',
        formatter: '{b}',
      },
      lineStyle: {
        color: 'source',
        opacity: 0.3,
        curveness: 0.35
      },
      emphasis: {
        lineStyle: {
          opacity: 1,
          width: 5,
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
      // top: AXIS_TOP,
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
    console.log(orig, size);
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
        formatter: p => p.dataType === 'node' ? `${p.data.tech.name}: ${p.name} (${p.data.type.name})` : '',
      },
      legend: [{
        left: 15,
        orient: 'vertical',
        data: categories.map(c => c.name),
        textStyle: {
          fontFamily: 'Roboto, sans-serif',
        }
      }],
      animationDuration: 1500,
      animationEasingUpdate: 'quinticInOut',
      series: [
        this.serviceSeries(data, links, categories),
        // this.techSeries(data),
      ],
    };
  }

  setOptions() {

    const data = this.chartData();
    const categories = toArray(TechType).map(c => ({
      ...c,
      itemStyle: {
        color: c.color || null
      }
    }));
    const links = ServiceLinks
      .filter(l => l.source && l.target)
      .map(({source, target}) => ({source: source.id, target: target.id}));

    const options = this.chartOptions(data, links, categories);
    this.context.set('services.chart', options);

  }

  handleChart(chart) {
    chart.on('legendselectchanged', params => {
      const { selected } = params;
      this.context.set('hide', {
        oci: !selected[TechType.OCI.name],
        oke: !selected[TechType.OKE.name],
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