const router = require('express').Router();
const config = require('../../config');
const mock = require('../mock');

// kv pairs of services in mock mode
const mockMode = Object.keys(mock.mocks).map(name => ({
  [name]: !!mock.mocks[name].enabled
}));

// other app settings
const { setting } = config.keyMap();
const settings = {
  // config for object storage bucket
  staticAssetPrefix: config.env(setting.STATIC_MEDIA) || '',
};

// Basic app config runtime
router.get('/config', (req, res) => res.json({
  ...settings,
  mockMode,
}));

module.exports = router;