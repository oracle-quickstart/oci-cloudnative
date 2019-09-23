/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

/**
 * Main Mu entrypoint
 */
export { Mu, MuMx } from './mu';
export * from './bindings';
export * from './util';

// attach micro/macro to mu
import './logical'; // if/each/attr/class/html
import './handlers'; // click/change/submit
