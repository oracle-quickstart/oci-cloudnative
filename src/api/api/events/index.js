/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const router = require('express').Router();
const helpers = require('../../helpers');

/**
 * forward client events
 */
router.post('/events', (req, res, next) => {
  return helpers.trackEvents(req, req.body)
    .then(() => res.send())
    .catch(next);
});

module.exports = router;