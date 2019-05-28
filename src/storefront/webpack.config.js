const path = require('path');
const webpack = require('webpack');

const package = require('./package.json');
const buildDir = path.resolve(__dirname, 'build');

//https://objectstorage.us-phoenix-1.oraclecloud.com/n/intvravipati/b/mushop-images/o/MU-US-001.png

const { NODE_ENV, STATIC_ASSET_URL } = process.env;

/**
 * This config is extended by gulp
 */
module.exports = {
  entry: {
    uikit: ['./src/scripts/uikit.js'],
    app: ['./src/scripts/app.js'],
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
    new webpack.DefinePlugin({
      VERSION: JSON.stringify(package.version),
      PRODUCTION: JSON.stringify(NODE_ENV === 'production'),
      STATIC_ASSET_URL: JSON.stringify(STATIC_ASSET_URL),
    }),
  ],
};
