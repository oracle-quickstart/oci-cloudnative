
/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const https = require('https');
const crypto = require('crypto');
const httpSignature = require('http-signature');
const forge = require('node-forge');
const { HEADERS, API_SIGNATURE_VERSION } = require('./constants');

/**
 * Headers always used in signing
 */
const SIGNED = [
  HEADERS.HOST,
  HEADERS.DATE,
  HEADERS.TARGET,
];

/**
 * Headers used in signing requests with body contents
 */
const SIGNED_CONTENT = [
  ...SIGNED,
  HEADERS.CONTENT_TYPE,
  HEADERS.CONTENT_LENGTH,
  HEADERS.CONTENT_HASH,
];

/**
 * list of method types with body contents
 */
const METHODS_WITH_CONTENT = ['POST', 'PUT', 'PATCH'];

/**
 * Sign request options using API key credentials
 * @see https://docs.cloud.oracle.com/Content/API/Concepts/signingrequests.htm
 * @param {https.Request} request - https request to sign
 * @param {object} auth - API signing configuration
 * @param {string|Buffer} auth.key - API Key
 * @param {string} auth.fingerprint - API Key fingerprint
 * @param {string} auth.tenancyId - Tenancy OCID
 * @param {string} auth.userId - Tenancy User OCID
 * @param {string} [body] - Optional content body
 * @return {void} - request options are modified
 */
function signRequest(request, auth, body) {

  // create initial signing options
  const signingOptions = {
    key: auth.key,
    keyId: `${auth.tenancyId}/${auth.userId}/${auth.fingerprint}`,
    headers: SIGNED,
  };

  // determine if the request body content should used in signing
  if (isHashableMethod(request.method)) {
    request.setHeader(HEADERS.CONTENT_HASH, createHash(body || ''));
    signingOptions.headers = SIGNED_CONTENT;
  }

  // sign with http-signature
  httpSignature.sign(request, signingOptions);

  // specify signature version
  request.setHeader(HEADERS.AUTHORIZATION, request.getHeader(HEADERS.AUTHORIZATION)
    .replace(/^Signature(\sversion\=['"\w\.]{3,})?/, `Signature version="${API_SIGNATURE_VERSION}",`));
}

/**
 * password protected pem key decryption
 * @param {string|Buffer} key 
 * @param {string} passphrase 
 */
function decryptedAuthKey(key, passphrase) {
  return passphrase ? forge.pki.decryptRsaPrivateKey(key, passphrase) : key;
}

/**
 * check if request body must be hashed
 * @param {string} method - request method to check
 * @returns {boolean}
 */
function isHashableMethod(method) {
  return METHODS_WITH_CONTENT.indexOf(method.toUpperCase()) > -1;
}


/**
 * Create a hash of the request body
 * @param {string|Buffer} body 
 * @return {string}
 */
function createHash(body) {
  return crypto.createHash('sha256')
    .update(body)
    .digest('base64');
}

/**
 * signing module
 */
module.exports = {
  signRequest,
  decryptedAuthKey,
  isHashableMethod,
  HEADERS,
};
