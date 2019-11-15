/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

import axios from 'axios';
import { Mu } from '../mu';
import { MUSHOP } from './constants';

export function ApiClient() {
  return axios.create({
    baseURL: '/api',
    withCredentials: true,
  });
}

export default Mu.macro(MUSHOP.MACRO.HTTP, ApiClient);
