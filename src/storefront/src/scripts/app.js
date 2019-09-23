/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */

// load deps
import { Mu } from './mu';

// load mushop
import './shop';

// Run Mu Shop
export default Mu.run(document.getElementById('app'), {
  root: '#app',
  baseViewUrl: 'views',
});
