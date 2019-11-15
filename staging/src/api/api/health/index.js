/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const router = require('express').Router();

// Basic service healthcheck
router.get('/health', (req, res) => res.send('OK'));

module.exports = router;