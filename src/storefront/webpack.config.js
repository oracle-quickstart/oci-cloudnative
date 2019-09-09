/**
 * Copyright © 2019, Oracle and/or its affiliates. All rights reserved.
 * The Universal Permissive License (UPL), Version 1.0
 */
const path = require('path');
const webpack = require('webpack');

const pkg = require('./package.json');
const buildDir = path.resolve(__dirname, 'build');

const { NODE_ENV } = process.env;

/**
 * This config is extended by gulp
 */
module.exports = {
  entry: {
    app: ['./src/scripts/app.js'],
    charts: ['./src/scripts/charts.js'],
    uikit: ['./src/scripts/uikit.js'],
  },
  output: {
    path: buildDir,
    publicPath: '/',
    filename: "scripts/[name].js",
  },
  // optimization: {
  //   usedExports: true,
  // },
  resolve: {
    extensions: [ ".js" ],
  },
  module: {
    rules: [
      {
        test: /\.(js)$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      },
    ]
  },
  plugins: [
    new webpack.BannerPlugin({
      banner: `Copyright © ${new Date().getFullYear()}, Oracle and/or its affiliates. All rights reserved.\nThe Universal Permissive License (UPL), Version 1.0`
    }),
    new webpack.DefinePlugin({
      VERSION: JSON.stringify(pkg.version),
      PRODUCTION: JSON.stringify(NODE_ENV === 'production'),
      TIMESTAMP: JSON.stringify(Date.now()),
    }),
  ],
};
