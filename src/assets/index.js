const path = require('path');
const http = require('http');
const static = require('node-static');
const config = require('./config.json');

// allow specific port when multiple services running on instance
const { PORT_ASSETS, PORT } = process.env;
const port = PORT_ASSETS || PORT || 3000;

// create simple static asset server
const files = new static.Server(path.join(__dirname, config.dist));
http.createServer((req, res) => {
  if (req.url === '/health') {
    res.write('OK');
    res.end();
  } else {
    req.addListener('end', () => files.serve(req, res))
      .resume();
  }
}).listen(port, () => {
  console.log(`Serving assets on :${port}`);
});