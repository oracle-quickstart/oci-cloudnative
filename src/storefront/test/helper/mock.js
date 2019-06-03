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
  jest.spyOn(view.loader, 'get').mockImplementation(file => {
    const template = path.join(dir, file);
    return new Promise((resolve, reject) => {
      fs.readFile(template, (err, html) => err ? reject(err) : resolve(MockHttp.response(html)));
    });
  });
}

export class MockMu {

  static mock(options = {}) {
    return new MockMu(options);
  }

  constructor(options = {}) {
    // noop logging from within the logger
    jest.spyOn(MuLogger.prototype, 'init').mockImplementation(function() {
      const noop = (() => {});
      Object.keys(console).forEach(k => this[k] = noop);
    });

    const id = 'mockapp';
    document.body.innerHTML = `<div id="${id}"></div>`;

    // instantiate mu
    const { mu, view } = Mu.init(document.getElementById(id), {
      root: `#${id}`,
      ...options
    });

    // grab constituents
    this.mu = mu;
    this.view = view;

    mockHttpViewLoader(view);
  }

  silence(emittable) {
    jest.spyOn(emittable, 'emit').mockReturnThis();
    jest.spyOn(emittable, 'emitOnce').mockReturnThis();
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
   * mock a response
   * @param {Mu} mu 
   * @param {string} method 
   * @param {Promise<object>} [response] - mock response payload
   */
  static mock(mu, method, response) {
    const { [MUSHOP.MACRO.HTTP]: http } = mu;
    jest.spyOn(http, method).mockResolvedValueOnce(response);
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

}