const fs = require('fs');
const path = require('path');
const mime = require('mime');
const axios = require('axios');

const config = require('./config');
// determine if pushing to bucket is intended
if (!config.rawParUrl) {
  console.log('PAR not provided, exiting with nothing to do');
  process.exit(0);
}

const putImage = (dir, img) => {
  const mType = mime.getType(img);
  const data = fs.readFileSync(path.join(dir, img));
  const fname = img;
  return axios({
    data,
    baseURL: config.parUrl,
    url: fname,
    method: 'PUT',
    headers: {
      'Content-Type': mType,
      'Cache-Control': `max-age=${config.cache.maxAge}, public, no-transform`,
    }
  })
  .then(() => console.log(`PUT Success: ${img}`))
  .catch(e => console.error(e.toString()));
};

if (config.parUrl) {
  const dist = path.join(__dirname, config.dist);
  if (fs.existsSync(dist)) {
    const files = fs.readdirSync(dist);
    Promise.all(files.map(f => putImage(dist, f)));
  }
} else {
  console.error('Invalid Object Storage PAR');
  process.exit(1);
}