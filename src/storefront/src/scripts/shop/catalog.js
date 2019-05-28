import { Mu, MuMx, attrToSelector, MuCtxInheritOnly, MuCtxSetterMixin } from '../mu';
import { ShopMxSubscriber } from './helper/subscriber';
import { ViewTemplateMixin } from './helper/viewmx';
import { MxCtxInsulator } from './helper/mixins';

const CATEGORY_RULES = {
  // name --> matches
  "feeders":    [/(feeder|bowl|placemat|storage)/i],
  "food":       [/(food|diet)/i],
  "grooming":   [/(groom|brush|shampoo)/i],
  "cat litter": [/(litter|clean|odor)/i],
};

const CATALOG_MU = {
  CATEGORY: 'mu-category',
  PRODUCTS: 'mu-products',
  PRODUCT: 'mu-product',
  TILE: 'mu-product-tile',
};

export function getStaticUrl(src) {
  const prefix = (STATIC_ASSET_URL || '/api/catalogue/images').replace(/\/$/, '');
  return `${prefix}/${src.replace(/^\//, '')}`;
}

export class CatalogController {
  constructor() {
    this._serviceUri = '/catalogue';
    this._serviceReg = new RegExp(`^(${this._serviceUri})`);
    this._normalize = this._normalize.bind(this);
    this._handleRes = this._handleRes.bind(this);
    console.log({ STATIC_ASSET_URL, PRODUCTION })
  }

  _normalize(product) {
    // create route link
    product.href = `product.html?id=${product.id}`;
    // map product images from API to the respective ingress
    product.imageUrl = (product.imageUrl || []).map(getStaticUrl);
    product.image = product.imageUrl[0];
    // fix price format
    product.priceDecimal = product.price;
    product.price = product.price.toFixed(2);
    // create pseudo shortdesc
    product.shortDescription = product.description.split('.').shift();
    // create pseudo type/attributes
    product.type = (product.tags || product.category || []).join(', ');
    product.attributes = ['weight', 'product_size', 'colors']
      .filter(p => product[p] && product[p] !== "0")
      .map(p => ({ name: p.replace(/[_-]/, ' '), value: product[p] }));
    // backcompat
    product.count = product.count || product.qty || 0;
    product.name = product.name || product.title || '';

    return product;
  }

  _handleRes(res) {
    if (res.data && !(res.data.status_code > 200)) {
      return res.data;
    } else {
      return Promise.reject(`${res.data.status_text}: ${res.data.error}`);
    }
  }

  categories() {
    return this.mu.api.get('/categories')
      .then(this._handleRes)
      .then(d => d.categories);
  }

  search(params) {
    const { router, api } = this.mu;
    const qs = typeof params === 'string' ? params : router.querystring(params || {});
    return api.get(`${this._serviceUri}?${qs}`)
      .then(this._handleRes)
      .then(data => data.map(this._normalize));
  }

  product(id) {
    return this.mu.api.get(`${this._serviceUri}/${id}`)
      .then(this._handleRes)
      .then(sku => this._normalize(sku));
  }
}





export class CategoryPage extends MuMx.compose(null, 
  MxCtxInsulator,
  ShopMxSubscriber,
  ViewTemplateMixin,
) {
  
  onInit() {

    this.skusLoaded = this.skusLoaded.bind(this);
    this.connectGrid = this.connectGrid.bind(this);
    this.subscribe('products', this.context, this.connectGrid);

  }

  onMount() {
    super.onMount();
    const { router, root } = this.mu;
    const { category, search } = router.queryparams() || {};

    // update page title
    root.context.set('page.title', category || (search && 'Search') || 'Browse');

    // rules
    const rules = CATEGORY_RULES[(category || '').toLowerCase()];

    // configure context binding
    return this.render({
      filterChange: this.filterChange.bind(this),
      search: {
        category: rules || category,
        term: search,
      }
    });
  }

  /**
   * when products mu mounts
   * @param {Products} products 
   */
  connectGrid(products) {
    products.on('loaded', this.skusLoaded);
  }

  /**
   * handle skus from products grid api call
   * @param {*} skus 
   */
  skusLoaded(skus) {
    const brands = this._propGroup(skus, 'brand');
    const categories = this._propGroup(skus, 'category');
    this.context.extend('filter.options', { brands, categories });
  }

  /**
   * filter form change handler
   * @param {*} e 
   * @param {*} form 
   */
  filterChange(e, form) {
    this.context.set('filter.values', form.getData());
  }

  /**
   * create an attribute grouping from sku results
   * @param {*} skus 
   * @param {*} prop 
   */
  _propGroup(skus, prop) {
    const hash = skus.map(sku => [].concat(sku[prop]))
      .reduce((g, vals) => {
        vals.forEach(val => g[val] = (g[val] || 0) + 1);
        return g;
      }, {});

    return Object.keys(hash)
      .map(value => ({
        value,
        count: hash[value]
      }))
  }

}



/**
 * self-loading products grid
 */
export class Products extends MuMx.compose(null,
  ViewTemplateMixin,
  [MuCtxSetterMixin, 'ref'],
) {

  onMount() {
    // console.log('cat.products', 'MOUNT', this.context._id, this.node.parentNode);
    super.onMount();
    this.context.extend({
      // state
      error: null,
      loading: false,
      pagination: {
        max: this._ctxProp('max') || 1e3,
        limit: ~~this._ctxProp('limit'),
        page: 1,
      },
      // actions
      layout: {
        change: {
          grid: this.setLayout.bind(this, 'grid'),
          list: this.setLayout.bind(this, 'list'),
        }
      },
    });

    // subscribe to context-provided filters
    this.context.on(this._ctxKey('filter'), this.filterChanged.bind(this));

    // Handle load on context-provided property
    const delegate = this._ctxKey('delegate');
    return delegate ?
      this.context.always(delegate, s => s && this.load()) :
      this.load();
  }

  /**
   * provide the view
   */
  viewTemplateDelegate() {
    return this._ctxProp('template') || 'productGrid.html';
  }

  setLayout(type, e) {
    const switcher = this.context.get('layout.switch');
    switcher.show(type === 'list' ? 1 : 0);
    this.context.set(`layout.list`, false).set(`layout.grid`, false);
    this.context.set(`layout.${type}`, true);
  }

  load() {
    // console.log('cat.products', 'LOAD', this.context._id);
    const { catalog } = this.mu;
    const { max } = this.context.get('pagination');
    // const { category } = this._ctxAttrValue('delegate') || {};
    // const categories = category && [].concat(category || []);
    const params = {
      ...(max ? { size: max } : {}), // limit total results
      // TODO: fix broken filtering
      // ...(category ? {
      //   categories: categories.join(','),
      //   tags: categories.join(','), // backcompat
      // }: {}),
    };
    
    this.render({ loading: true })
      .then(() => catalog.search(params))
      .then(all => {
        // apply shallow filter on the delegated search pre-conditions
        const matched = this.filter(all, true);
        this.emit('loaded', matched);
        return this.renderMatched(matched);
      })
      .catch(error => this.render({
        error,
        items: null,
        loading: false,
       }));
  }

  renderPage(items, page) {
    const { limit } = this.context.get('pagination');
    const numPages = limit ? Math.ceil(items.length / limit) : 1;
    const slice = limit ? items.slice().slice((page - 1) * limit, page * limit) : items;
    
    // create client-pagination bindings
    const prev = page > 1 && this.renderPage.bind(this, items, page - 1);
    const next = page < numPages && this.renderPage.bind(this, items, page + 1);
    const hasMore = !!next;
    const pages = Array.apply(null, Array(numPages)).map((n, i) => ({
      number: i + 1,
      isCurrent: page === i + 1,
      click: this.renderPage.bind(this, items, i + 1),
    }));

    // render page with pagination bindings
    return this.render({
      loading: false,
      error: !items.length && 'No products found',
      items: slice, // this page of items
      pages, // paging
      hasMore,
      actions: {
        prev,
        next, // next page button
      },
    });
  }

  /**
   * filter items and render
   * @param {object[]} all - full set of pre-filtered results
   */
  renderMatched(all) {
    this._all = all || this._all;
    return this.renderPage(this.filter(this._all), 1);
  }

  /**
   * respond to upstream filter changes
   */
  filterChanged() {
    return this.renderMatched();
  }


  /**
   * reduce items to those statisfying the filters
   * @param {object[]} items 
   * @param {boolean} shallow
   */
  filter(items, shallow) {
    const { category, term } = this._ctxAttrValue('delegate') || { };
    const filters = this._ctxAttrValue('filter') || { };
    const omit = this._ctxAttrValue('omit');
    const { priceMin, priceMax, text = term } = filters;
    
    // construct criteria
    const cat = [].concat(category || [], filters.categories || []);
    const match = {
      cat: cat.filter(c => !(c instanceof RegExp)),
      catRx: cat.filter(c => c instanceof RegExp),
      // apply other filters after shallow
      ...(shallow ? { } : {
        search: (text || '').toLowerCase(),
        brand: [].concat(filters.brands || []),
        min: priceMin && parseFloat(priceMin.replace(/[^\d\.]/, '')),
        max: priceMax && parseFloat(priceMax.replace(/[^\d\.]/, '')),
      })
    };
    // console.log(match);
    // apply the filters
    return (items || []).filter(item => {
      // explicit omission
      if (omit === item.id) {
        return false;
      }

      const tests = [];
      // match category
      if (match.cat.length) {
        tests.push(item.category.reduce((pass, cat) => {
          return pass || match.cat.indexOf(cat) > -1;
        }, false));
      }
      if (match.catRx.length) {
        tests.push(item.category.reduce((pass, cat) => {
          return pass || !!match.catRx.filter(r => r.test(cat)).length;
        }, false));
      }
      // match brand
      if (match.brand && match.brand.length) {
        tests.push(match.brand.indexOf(item.brand) > -1);
      }
      // title 
      if (match.search) {
        tests.push(item.title.toLowerCase().indexOf(match.search) > -1);
      }
      // price
      if (match.min) {
        tests.push(item.priceDecimal >= match.min);
      }
      if (match.max) {
        tests.push(item.priceDecimal <= match.max);
      }
      
      // if any failures -> falsy
      return tests.length && tests.filter(p => !p).length ? false : true;
    });
  }
}



export class SingleProduct extends MuMx.compose(null, 
  MxCtxInsulator,
  ShopMxSubscriber,
  ViewTemplateMixin,
) {
  
  onMount() {
    super.onMount();
    return Promise.resolve(this._ctxAttrValue('product') || this.pageLoad())
      .then(product => this.render({
        product,
        loading: false,
        atc: this.addToCart.bind(this),
      }))
      .catch(error => this.render({ error, loading: false }));
  }

  pageLoad() {
    const { router, catalog, page, root } = this.mu;
    return new Promise((resolve, reject) => {
      this.render({ loading: true });
      page.on('page', name => {
        if (name === 'product') {
          this.context.on('product', p => root.context.set('page.title', p.title))
          const { id } = router.queryparams();
          resolve(this.render({ loading: true })
            .then(() => catalog.product(id)))
        } else {
          reject('Unknown context for product');
        }
      });
      
    });
  }

  viewTemplateDelegate() {
    const template = this._ctxProp('template');
    return template === 'contents' ? null : (template || 'productCard.html');
  }

  addToCart() {
    const item = this.context.get('product');
    return this.mu.cart.add(item, 1);
  }
}

export default Mu.macro('catalog', CatalogController)
  .micro('cat.category', attrToSelector(CATALOG_MU.CATEGORY), CategoryPage)
  .micro('cat.products', attrToSelector(CATALOG_MU.PRODUCTS), Products)
  .micro('sku.product', attrToSelector(CATALOG_MU.PRODUCT), SingleProduct)
  .micro('sku.tile', attrToSelector(CATALOG_MU.TILE), SingleProduct);
