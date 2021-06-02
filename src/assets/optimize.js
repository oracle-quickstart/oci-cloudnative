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
    pngquant({quality: [0.3, 0.5]}),
    jpegtran({progressive: true}),
    mozjpeg({progressive: true, quality: 45}),
  ],
}).then(files => console.log(`Optimized ${files.length} images in ./${dir}`));

Promise.all(['hero', 'products'].map(optimize))
  .catch(e => {
    console.error(e);
    process.exit(1);
  });
