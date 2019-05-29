const gulp         = require('gulp'),
      util         = require('gulp-util'),
      less         = require('gulp-less'),
      sync         = require('browser-sync'),
      // concat       = require('gulp-concat'),
      webpack      = require('webpack-stream'),
      del          = require('del'),
      imagemin     = require('gulp-imagemin'),
      pngquant     = require('imagemin-pngquant'),
      cache        = require('gulp-cache'),
      autoprefixer = require('autoprefixer'),
      postcss      = require('gulp-postcss'),
      csso         = require('gulp-csso'),
      pug          = require('gulp-pug'),
      proxy        = require('http-proxy-middleware');

// load .env configurations
require('dotenv').config();

// HTML
const pugOpt = {
  basedir: 'src/templates',
  doctype: 'html',
  pretty: true,
};

gulp.task('html:pages', function() {
  return gulp.src('src/templates/pages/**/*.pug')
    .pipe(pug(pugOpt))
    .pipe(gulp.dest('build'))
    .pipe(sync.stream())
});

gulp.task('html:views', function() {
  return gulp.src('src/templates/views/**/*.pug')
    .pipe(pug(pugOpt))
    .pipe(gulp.dest('build/views'))
    .pipe(sync.stream())
});

gulp.task('html', gulp.parallel('html:pages', 'html:views'));

// Styles

gulp.task('styles', function() {
  return gulp.src(['src/styles/**/*.less', '!src/styles/**/_*.less'])
    .pipe(less({ relativeUrls: true }))
    // .pipe(concat('style.css'))
    .pipe(postcss([autoprefixer({ browsers: 'last 2 versions' })]))
    .pipe(csso())
    .pipe(gulp.dest('build/styles'))
    .pipe(sync.stream({
      once: true
    }));
});

// Scripts

gulp.task('scripts', function() {
  const wpconf = require('./webpack.config');
  const { production } = util.env;
  return gulp.src('src/scripts/*.js')
    .pipe(webpack({
      ...wpconf,
      mode: production ? 'production' : 'development',
      devtool: production ? false : 'eval',
    }))
    .pipe(gulp.dest('build'))
    .pipe(sync.stream({
      once: true
    }));
});

// Images

gulp.task('images', function() {
  return gulp.src(['src/images/**/*'])
    .pipe(cache(imagemin({
      interlaced: true,
      progressive: true,
      svgoPlugins: [{ removeViewBox: false }],
      use: [pngquant()]
    })))
    .pipe(gulp.dest('build/images'));
});

// Copy

gulp.task('copy', function() {
  return gulp.src([
    'src/*',
    'src/fonts/*',
    '!src/images/*',
    '!src/styles/*',
    '!src/scripts/*'
  ], {
    base: 'src'
  })
    .pipe(gulp.dest('build'))
    .pipe(sync.stream({
      once: true
    }));
});

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
    middleware: [ proxy('/api', {
      target: API_PROXY,
      pathRewrite: { '^/api': '' },
    }) ],
    server: {
      baseDir: 'build'
    }
  });
});

// Clean

gulp.task('clean', function() {
  return del('build');
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
    'src/fonts/*',
    '!src/images/*',
    '!src/styles/*',
    '!src/scripts/*'
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
  )
));

// Default

gulp.task('default', gulp.series(
  'build',
  gulp.parallel(
    'watch',
    'server'
  )
));
