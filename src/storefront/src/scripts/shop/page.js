import { Mu } from '../mu';
import { getDocument } from '../util/window';

const alias = { home: [/^\/$/] };
const pages = {
  '404':      '404.html',
  '50x':      '50x.html',
  auth:       'auth.html',
  about:      'about.html',
  article:    'article.html',
  blog:       'blog.html',
  brands:     'brands.html',
  cart:       'cart.html',
  catalog:    'catalog.html',
  category:   'category.html',
  checkout:   'checkout.html',
  compare:    'compare.html',
  contact:    'contacts.html',
  delivery:   'delivery.html',
  faq:        'faq.html',
  favorites:  'favorites.html',
  home:       'index.html',
  news:       'news.html',
  orders:     'orders.html',
  personal:   'personal.html',
  product:    'product.html',
  settings:   'settings.html',
  subcategory:'subcategory.html'
};

const authPage = 'auth';
const errPage = '50x';
const nfPage = '404';
const restricted = ['personal', 'settings', 'orders', 'checkout'];

function pageHref(page) {
  return pages[page];
};

export class PageController {
  constructor(document) {
    // handle mu initialization
    this.mu.on('ready', this._init.bind(this));
    this.document = document;
  }

  _init() {
    this._bindRouter();
    this._bindAuth();
  }

  _bindAuth() {
    const { user } = this.mu;
    this.context.on('user.ready', () => {
      user.always('user.profile', this._aclUpdate.bind(this));
    });
  }

  _bindRouter() {
    const { router } = this.mu;

    // register pages with the router
    Object.keys(pages).forEach(route => {
      router.register(route, pages[route], alias[route]);
    });

    // add router listeners
    router.on('back', state => {
      var page = (state && state.name);
      return page && this._aclGate(page);
    }).on('update', this._aclGate.bind(this));
  }
  
  _isDeny(page) {
    return (!this._hasAuth && !!~restricted.indexOf(page));
  }

  _aclGate(page, search, params) {
    const deny = this._isDeny(page);
    console.log('ACL CHECK', page, { deny });
    if (deny) {
      this._authRedir = { page, search, params };
      this.mu.router.go(authPage, null, null, true);
    } else {
      this.update(page, search, params);
    }
  }

  _aclUpdate(profile) {
    const auth = this._hasAuth = !!profile;
    const current = this.mu.router.initial(nfPage);
    console.log('ACL CHANGE', auth, current);
    const authRedir = this._authRedir; // case when auth was requried due to prior nav 
    if (authRedir) {
      this._authRedir = null; // clear 
      const { page, search, params } = authRedir;
      this._aclGate(page, search, params);
    } else if (this._isDeny(current)) {
      this._aclGate(current);
    } else {
      return current === nfPage ? router.go(nfPage) : this.setPage(current);
    }
  }

  setPage(page) {
    this.document.title = `MuShop::${this.pageName(page)}`;
    this.emit('page', page);
    this.emit(page);
  }

  pageName(page) {
    return page.charAt(0).toUpperCase() + page.slice(1);
  }
  
  update(page, search, params) {
    return this.load(page).then(this.setPage.bind(this, page));
  }

  /**
   * load a new page
   */
  load(page) {
    const url = pageHref(page);
    return this.view.load(url)
      .then(html => {
        const { root } = this.mu;
        root.context.set('page.title', this.pageName(page));
        // update root dom
        const node = this.view.virtual(html, root.selector); // render full page in virtual DOM
        this.view.apply(root.element, (node ? node.innerHTML : html)); // swap root content
      }).catch(e => {
        console.error(page, e);
        return page !== errPage ? this.load(errPage) : Promise.reject(e);
      });
  }

}

export default Mu.macro('page', PageController, getDocument());
