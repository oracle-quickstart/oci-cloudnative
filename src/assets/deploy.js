/**
 * Copyright © 2020, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const fs = require('fs');
const path = require('path');
const mime = require('mime');
const config = require('./config');
const { HttpClient } = require('./lib');

const http = new HttpClient();

const putImage = (dir, img) => {
  const mType = mime.getType(img);
  const data = fs.readFileSync(path.join(dir, img));
  const fname = img;

  return http.request(config.parUrl + fname, {
    method: 'PUT',
    body: data,
    headers: {
      'Content-Type': mType,
      'Cache-Control': `max-age=${config.cache.maxAge}, public, no-transform`,
    }
  })
  .then(() => console.log(`PUT Success: ${img}`))
  .catch(e => console.error(e.toString()));
};

// determine if pushing to bucket is intended
if (!config.rawParUrl) {
  console.log('PAR not provided, exiting with nothing to do');
  process.exit(0);
} else if (config.parUrl) {
  const dist = path.join(__dirname, config.dist);
  if (fs.existsSync(dist)) {
    const files = fs.readdirSync(dist);
    Promise.all(files.map(f => putImage(dist, f)));
  } else {
    console.error(`Optimized image directory does not exist: ${config.dist}`);
    process.exit(1);  
  }
} else {
  console.error('Invalid Object Storage PAR');
  process.exit(1);
}