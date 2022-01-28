const gulp     = require('gulp'),
  fs           = require('fs'),
  path         = require('path'),
  argv         = require('minimist')(process.argv.slice(2)),
  less         = require('gulp-less'),
  header       = require('gulp-header'),
  rev          = require('gulp-rev'),
  revReplace   = require('gulp-rev-replace'),
  sync         = require('browser-sync'),
  webpack      = require('webpack-stream'),
  del          = require('del'),
  imagemin     = require('gulp-imagemin'),
  pngquant     = require('imagemin-pngquant'),
  cache        = require('gulp-cache'),
  autoprefixer = require('autoprefixer'),
  postcss      = require('gulp-postcss'),
  csso         = require('gulp-csso'),
  pug          = require('gulp-pug'),
  proxy        = require('http-proxy-middleware'),
  pkg          = require('./package.json');

// load .env configurations
require('dotenv').config();

const opt = {
  buildDir: 'build'
};

const scriptBanner = [
  '/**',
  `* Copyright © ${new Date().getFullYear()}, Oracle and/or its affiliates. All rights reserved.`,
  '* The Universal Permissive License (UPL), Version 1.0',
  '*/'
].join('\n');

// load env

// load ci version
const VERSION = process.env.VERSION || fs.readFileSync(path.join(__dirname, 'VERSION')).toString();

// Static HTML build
const pugOpt = {
  basedir: 'src/templates',
  doctype: 'html',
  pretty: true,
  data: {
    VERSION,
    TIMESTAMP: new Date().toISOString().split('.').shift(),
  }
};

gulp.task('html:pages', function() {
  return gulp.src('src/templates/pages/**/*.pug')
    .pipe(pug(pugOpt))
    .pipe(gulp.dest(opt.buildDir))
    .pipe(sync.stream({ once: true }))
});

gulp.task('html:views', function() {
  return gulp.src('src/templates/views/**/*.pug')
    .pipe(pug(pugOpt))
    .pipe(gulp.dest(`${opt.buildDir}/views`))
    .pipe(sync.stream({ once: true }))
});

gulp.task('html', gulp.parallel('html:pages', 'html:views'));

// Styles
gulp.task('styles', function() {
  return gulp.src(['src/styles/**/*.less', '!src/styles/**/_*.less'])
    .pipe(less({ relativeUrls: true }))
    // .pipe(concat('style.css'))
    .pipe(postcss([autoprefixer()]))
    .pipe(csso())
    .pipe(header(scriptBanner))
    .pipe(gulp.dest(`${opt.buildDir}/styles`))
    .pipe(sync.stream({
      once: true
    }));
});

// Scripts
gulp.task('scripts', function() {
  const wpconf = require('./webpack.config');
  const { production } = argv;
  return gulp.src('src/scripts/*.js')
    .pipe(webpack({
      ...wpconf,
      mode: production ? 'production' : 'development',
      devtool: production ? false : 'eval',
    }))
    .pipe(gulp.dest(opt.buildDir))
    .pipe(sync.stream({
      once: true
    }));
});

// Scripts Extras
gulp.task('oda:copy', function() {
  return gulp.src('src/scripts/oda/*')
    .pipe(gulp.dest(`${opt.buildDir}/scripts/oda`))
});

gulp.task('extras', gulp.series('oda:copy'));

// Images

// copy images into build
gulp.task('image:copy', function() {
  return gulp.src('src/images/**/*')
    .pipe(gulp.dest(`${opt.buildDir}/images`))
});

// optimize images 
gulp.task('image:optimize', function(done) {
  return gulp.src(`${opt.buildDir}/images/**/*`)
    .pipe(cache(imagemin([
      pngquant({quality: [0.3, 0.5]}),
      imagemin.gifsicle({interlaced: true}),
      imagemin.mozjpeg({progressive: true, quality: 55}),
      imagemin.svgo({
        plugins: [
          { removeViewBox: true },
        ]
      }),
    ])
      .on('error', e => done()) // gracefully fail
      .on('end', () => done())
    ))
    .pipe(gulp.dest(`${opt.buildDir}/images`));
});

gulp.task('images', gulp.series('image:copy', 'image:optimize'));

// Copy
gulp.task('copy', function() {
  return gulp.src([
    'src/*',
    '!src/images/*',
    '!src/styles/*',
    '!src/scripts/*',
    '!src/scripts/oda/*'
  ], {
    base: 'src'
  })
    .pipe(gulp.dest(opt.buildDir))
    .pipe(sync.stream({
      once: true
    }));
});

// Revision
gulp.task('rev', function() {
  return gulp.src([`${opt.buildDir}/scripts/**/*.js`, `${opt.buildDir}/styles/**/*.css`], {base: opt.buildDir})
    .pipe(rev())
    .pipe(gulp.dest(opt.buildDir))
    .pipe(rev.manifest())
    .pipe(gulp.dest(opt.buildDir))
});

gulp.task('rev:replace', gulp.series('rev', function() {
  const manifest = gulp.src(`${opt.buildDir}/rev-manifest.json`);
  return gulp.src([`${opt.buildDir}/*.html`])
    .pipe(revReplace({ manifest }))
    .pipe(gulp.dest(opt.buildDir));
}));

// Server

gulp.task('server', function() {
  // READ the API_PROXY environment variable for the shop services
  const { API_PROXY = 'http://localhost:8080' } = process.env;
  sync.init({
    notify: false,
    open: false,
    port: 3000,
    ui: false,
    routes: { '/': 'index.html' },
    middleware: [ proxy.createProxyMiddleware('/api', {
      target: API_PROXY,
      pathRewrite: { '^/api': '' },
    }) ],
    server: {
      baseDir: opt.buildDir
    }
  });
});

// Clean

gulp.task('clean', function() {
  return del(opt.buildDir);
});

// Clear

gulp.task('clear', function() {
  return cache.clearAll();
});

// Watch

gulp.task('watch:html', function() {
  return gulp.watch('src/templates/**/*.pug', gulp.series('html'));
});

gulp.task('watch:styles', function() {
  return gulp.watch('src/styles/**/*.less', gulp.series('styles'));
});

gulp.task('watch:scripts', function() {
  return gulp.watch('src/scripts/**/*.js', gulp.series('scripts'));
});

gulp.task('watch:copy', function() {
  return gulp.watch([
    'src/*',
    '!src/images/*',
    '!src/styles/*',
    '!src/scripts/*',
    '!src/scripts/oda/*'
  ], gulp.series('copy'));
});

gulp.task('watch', gulp.parallel(
  'watch:html',
  'watch:styles',
  'watch:scripts',
  'watch:copy'
));

// Build

gulp.task('build', gulp.series(
  'clean',
  gulp.parallel(
    'html',
    'styles',
    'scripts',
    'copy',
    'images',
    'extras',
  )
));

gulp.task('build:prod', gulp.series('clear', 'build', 'rev:replace'));

// Default

gulp.task('default', gulp.series(
  'build',
  gulp.parallel(
    'watch',
    'server'
  )
));
