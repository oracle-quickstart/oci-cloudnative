/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const https = require('https');
const querystring = require('querystring');
const { signRequest, isHashableMethod, decryptedAuthKey } = require('./sign');
const { HEADERS } = require('./constants');

class HttpClient {

  /**
   * Make an https request
   * @param {string} url - Https API URL
   * @param {https.RequestOptions} [options] - https request options @see https://nodejs.org/api/https.html#https_https_request_url_options_callback
   * @param {object} [options.body] - Optional body of request to be sent
   * @param {object} [options.query] - Optional object for query string params
   * @returns {Promise<response>}
   */
  request(url, options) {
    return new Promise((resolve, reject) => {
      // process options
      options = options || { };
      let { body, query } = options;

      // setup request
      const endpoint = url;
      if (typeof query === 'object') {
        url = url + (url.indexOf('?') === -1 ? '?' : '&') + querystring.stringify(query);
      }
  
      // start request
      const request = https.request(url, options, response => {
        let data = '';
        // hanlde response
        response
          .on('data', chunk => data += chunk)
          .on('end', () => {
            const { headers, statusCode } = response;
            // parse json
            if (headers['content-type'] === 'application/json') {
              data = JSON.parse(data);
            }
            const res = { statusCode, headers, data };
            // handle Promise resolution
            if (/^2/.test(statusCode)) {
              const last = (query || {}).page;
              const next = headers[HEADERS.NEXT_PAGE];
              if (next && next !== last) {
                res.nextPage = this.request.bind(this, endpoint, {
                  ...options,
                  query: {...(query || {}), page: next }
                });
              }
              resolve(res);
            } else {
              const err = new Error(`${response.statusCode}: ${response.statusMessage}`);
              err.response = res;
              reject(err);
            }
          })
      }).on('error', reject);
      
      // handle body
      if (body) {
        if (typeof body === 'object' && !body instanceof Buffer) {
          body = JSON.stringify(body);
          request.setHeader(HEADERS.CONTENT_TYPE, 'application/json');
        }
        request.setHeader(HEADERS.CONTENT_LENGTH, body.length);
      } else if (isHashableMethod(request.method)) {
        request.setHeader(HEADERS.CONTENT_TYPE, 'application/json');
        request.setHeader(HEADERS.CONTENT_LENGTH, 0);
      }

      // precondition & send
      this._precondition(request, body);
      request.end(body || undefined);
    });
  }

  /**
   * @private
   * @param {https.Request} request 
   * @param {*} [body]
   * @returns {void}
   */
  _precondition(request, body) { 

  }
}

/**
 * Simple http client for OCI API requests
 */
class OCIHttpClient extends HttpClient {

  /**
   * Configure client authentication for API signing
   * @param {object} config - API signing configuration
   * @param {string|Buffer} config.key - API Key
   * @param {string} [config.passphrase] - API Key passphrase
   * @param {string} config.fingerprint - API Key fingerprint
   * @param {string} config.tenancyId - Tenancy OCID
   * @param {string} config.userId - Tenancy User OCID
   * @returns {OCIHttpClient} - client with auth
   */
  constructor(config) {
    super();
    // validate
    ['key', 'fingerprint', 'tenancyId', 'userId']
      .forEach(k => {
        if (!(config && config[k])) {
          throw new Error(`Missing auth configuration property: '${k}'`);
        }
      });
    // configure auth
    const { key, passphrase, ...auth } = config;
    this._auth = {
      ...auth,
      key: decryptedAuthKey(key, passphrase),
    };
  }

  /**
   * sign the request
   */
  _precondition(request, body) {
    signRequest(request, this._auth, body);
  }
}

module.exports = {
  HttpClient,
  OCIHttpClient,
};
