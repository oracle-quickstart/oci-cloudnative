/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

/**
 * OCI API Signature version
 */
const API_SIGNATURE_VERSION = '1';

/**
 * Hash of header names used in signing and oci
 */
const HEADERS = {
  AUTHORIZATION:  'authorization',
  HOST:           'host',
  DATE:           'date',
  TARGET:         '(request-target)',
  CONTENT_TYPE:   'content-type',
  CONTENT_LENGTH: 'content-length',
  CONTENT_HASH:   'x-content-sha256',
  NEXT_PAGE:      'opc-next-page',
};

module.exports = {
  API_SIGNATURE_VERSION,
  HEADERS,
};
