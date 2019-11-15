const fs = require('fs');
const path = require('path');
const mime = require('mime');
const axios = require('axios');

require('dotenv').config();

const { BUCKET_PAR = '' } = process.env;
const config = require('./config.json');

const metaHeaders = Object.assign({}, ...Object.keys(config.headers)
  .map(k => ({[`opc-meta-${k}`]: config.headers[k]})));

const putImage = (dir, img) => {
  const mType = mime.getType(img);
  const data = fs.readFileSync(path.join(dir, img));
  const fname = img;
  return axios({
    data,
    baseURL: BUCKET_PAR,
    url: fname,
    method: 'PUT',
    headers: {
      ...metaHeaders,
      'Content-Type': mType,
    }
  })
  .then(() => console.log(`PUT success: ${img}`))
  .catch(e => console.error(e));
};

const parReg = /\/p\/([\w-]+)\/n\/([\w-]+)\/b\/([\w-]+)\/o\/$/;
if (parReg.test(BUCKET_PAR)) {
  const dist = path.join(__dirname, config.dist);
  if (fs.existsSync(dist)) {
    const files = fs.readdirSync(dist);
    Promise.all(files.map(f => putImage(dist, f)));
  }
} else {
  console.error('Invalid Object Storage PAR');
  process.exit(1);
}