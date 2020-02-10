/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const path = require('path');
const http = require('http');
const static = require('node-static');
const config = require('./config');

// allow specific port when multiple services running on instance
const { PORT_ASSETS, PORT } = process.env;
const port = PORT_ASSETS || PORT || 3000;

// create simple static asset server
const files = new static.Server(path.join(__dirname, config.dist), {
  cache: config.cache.maxAge,
});
http.createServer((req, res) => {
  if (req.url === '/health') { // health check
    res.write('OK');
    res.end();
  } else if (req.url === '/config') { // asset configuration
    res.write(config.bucketUrl || '');
    res.end();
  } else { // serve static
    req.addListener('end', () => files.serve(req, res))
      .resume();
  }
}).listen(port, () => {
  console.log(`Serving assets on :${port}`, config);
});