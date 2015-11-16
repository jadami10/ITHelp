var webpack = require('webpack');
var path = require('path');
var nib = require('nib');

var paths = {
  src: path.join(__dirname, 'src'),
  dest: path.join(__dirname, 'dist'),
};

module.exports = {
  entry: paths.src + '/entry.js',
  output: {
    path: paths.dest,
    filename: 'main.js',
  },

  module: {
    loaders: [
      {
        // ES6
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel',
      },
      {
        // Stylus
        test: /\.styl$/,
        loader: 'style!css!stylus',
      },
      {
        // Icon fonts
        test: /\.(eot|svg|ttf|woff)$/,
        loader: 'url?limit=100000',
      },
    ],
  },

  stylus: {
    use: [nib()],
  },
};
