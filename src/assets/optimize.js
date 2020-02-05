const path = require('path');
const imagemin = require('imagemin');
const pngquant = require('imagemin-pngquant');
const jpegtran = require('imagemin-jpegtran');
const mozjpeg = require('imagemin-mozjpeg');

const config = require('./config');
const dist = path.join(__dirname, config.dist);


const optimize = async dir => await imagemin([`${dir}/*`], {
  destination: dist,
  plugins: [
    pngquant(),
    jpegtran({progressive: true}),
    mozjpeg({quality: 85}),
  ],
}).then(files => console.log(`Optimized ${files.length} images in ./${dir}`));

Promise.all(['hero', 'products'].map(optimize))
  .catch(e => {
    console.error(e);
    process.exit(1);
  });
