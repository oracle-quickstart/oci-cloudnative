const router = require('express').Router();

// Basic service healthcheck
router.get('/health', (req, res) => res.send('OK'));

module.exports = router;