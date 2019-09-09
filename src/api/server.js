/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const app = require('./app');
const config = require("./config");

app.listen(config.env('PORT') || 3000, function () {
  var port = this.address().port;
  console.log("App now running in %s mode on port %d", app.get("env"), port);
});
