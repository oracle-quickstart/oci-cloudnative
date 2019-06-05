import * as fs from 'fs';
import * as path from 'path';
import { Mu } from '../../src/scripts/mu';
import { MUSHOP } from '../../src/scripts/shop/constants';
import { MuLogger } from '../../src/scripts/mu/mu';


/**
 * mock the http view loader
 * @param {MuView} view 
 */
function mockHttpViewLoader(view) {
  const dir = path.join(__dirname, '../../build');
  jest.spyOn(view.loader, 'get').mockImplementation(file => new Promise((resolve, reject) => {
    const template = path.join(dir, file);
    fs.readFile(template, (err, html) => err ? reject(err) : resolve(MockHttp.response(html)));
  }));
}

export class MockMu {

  static mock(options = {}) {
    return new MockMu(options);
  }

  constructor(options = {}) {
    options = {
      id: 'mockapp',
      ...options,
    };

    // noop logging from within the logger
    jest.spyOn(MuLogger.prototype, 'init').mockImplementation(function() {
      const noop = (() => {});
      Object.keys(console).forEach(k => this[k] = noop);
    });

    const { id } = options;
    document.body.innerHTML = `<div id="${id}"></div>`;

    // instantiate mu
    const { mu, view } = Mu.init(document.getElementById(id), {
      root: `#${id}`,
      ...options
    });

    // grab constituents
    this.mu = mu;
    this.view = view;
    this.http = MockHttp.mock(mu);

    mockHttpViewLoader(view);
  }

  silence(emittable) {
    jest.spyOn(emittable, 'emit').mockReturnThis();
    jest.spyOn(emittable, 'emitOnce').mockReturnThis();
    return this;
  }

  html(html) {
    this.mu.root.element.innerHTML = html;
    return this;
  }

  run() {
    return Mu.start(this.mu, this.view);
  }
}

export class MockHttp {

  /**
   * create mock spys of all http methods
   * @param {Mu} mu 
   */
  static mock(mu, method, response) {
    return new MockHttp(mu);
  }

  static response(data = {}, options = {}) {
    return Promise.resolve({
      data,
      status: 200,
      statusText: 'OK',
      headers: {},
      config: {},
      ...options
    });
  }

  static error(err = {}) {
    return Promise.reject(err);
  }

  constructor(mu) {
    const { [MUSHOP.MACRO.HTTP]: http } = mu;
    ['get', 'put', 'post', 'patch', 'delete', 'head', 'options']
      .forEach(m => this[m] = jest.spyOn(http, m).mockResolvedValue(MockHttp.response()));
  }

}