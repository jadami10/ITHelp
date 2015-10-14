var webpack = require('webpack');
var path = require('path');
var nib = require('nib');

var paths = {
  src: path.join(__dirname, 'src'),
  dest: path.join(__dirname, 'dist'),
};

module.exports = {
  entry: {
    solve: paths.src + '/scripts/solve.js',
    solving: paths.src + '/scripts/solving.js'
  },
  
  output: {
    path: paths.dest,
    filename: '[name].js',
  },

  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
      },
      {
        test: /\.styl$/,
        loader: 'style-loader!css-loader!stylus-loader',
      },
      {
        test: /\.(eot|svg|ttf|woff)$/,
        loader: 'url?limit=100000',
      }
    ],
  },

  stylus: {
    use: [nib()],
  },

  plugins: [

  ],
};
