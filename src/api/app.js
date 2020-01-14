/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
var express = require("express")
  , morgan = require("morgan")
  , bodyParser = require("body-parser")
  , cookieParser = require("cookie-parser")
  , session = require("express-session")
  , Config = require("./config")
  , helpers = require("./helpers")
  , mock = require("./api/mock")
  , cart = require("./api/cart")
  , catalogue = require("./api/catalogue")
  , config = require("./api/config")
  , orders = require("./api/orders")
  , user = require("./api/user")
  , metrics = require("./api/metrics")
  , health = require("./api/health")
  , newsletter = require("./api/newsletter")
  , app = express();

app.use(helpers.rewriteSlash);
app.use(metrics);
app.use(health);
app.use(session(Config.session()));

app.use(bodyParser.json());
app.use(cookieParser());
app.use(morgan(Config.prod() ? "combined" : "dev", {
  
}));

/* Mount API endpoints */
const api = express.Router();
api.use(health);
api.use(helpers.sessionMiddleware);
api.use(mock.layer());
api.use(config);
api.use(cart);
api.use(catalogue);
api.use(orders);
api.use(user);
api.use(newsletter);
// mount to app
app.use(api); // back-compat with weave
app.use('/api', api); // expose services as `/api/{service}`

app.disable('x-powered-by');
app.use(helpers.errorHandler);

module.exports = app;