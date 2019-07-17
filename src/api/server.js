var express = require("express")
  , morgan = require("morgan")
  , bodyParser = require("body-parser")
  , cookieParser = require("cookie-parser")
  , session = require("express-session")
  , config = require("./config")
  , helpers = require("./helpers")
  , cart = require("./api/cart")
  , catalogue = require("./api/catalogue")
  , orders = require("./api/orders")
  , user = require("./api/user")
  , metrics = require("./api/metrics")
  , health = require("./api/health")
  , app = express();

app.use(helpers.rewriteSlash);
app.use(metrics);
app.use(health);
app.use(session(config.session()));

app.use(bodyParser.json());
app.use(cookieParser());
app.use(morgan("dev", {}));

/* Mount API endpoints */
const api = express.Router();
api.use(health);
api.use(helpers.sessionMiddleware);
api.use(cart);
api.use(catalogue);
api.use(orders);
api.use(user);
// mount to app
app.use(api); // back-compat with weave
app.use('/api', api);

app.disable('x-powered-by');
app.use(helpers.errorHandler);

var server = app.listen(process.env.PORT || 3000, function () {
  var port = server.address().port;
  console.log("App now running in %s mode on port %d", app.get("env"), port);
});
