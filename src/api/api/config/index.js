/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const router = require('express').Router();
const config = require('../../config');
const mock = require('../mock');

// kv pairs of services in mock mode
const mockMode = Object.assign({}, ...Object.keys(mock.mocks).map(name => ({
  [name]: !!mock.mocks[name].enabled
})));

// other app settings
const { setting } = config.keyMap();
const settings = {
  // config for object storage bucket
  staticAssetPrefix: config.env(setting.CDN) || '',
};

const client = {
  ...settings,
  mockMode,
};

// Basic app config runtime
router.get('/config', (req, res) => res.json(client));

module.exports = router;