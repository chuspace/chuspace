const path = require('path')
const APP_SOURCE = path.join(__dirname, 'app/packs/lib')
const TerserPlugin = require('terser-webpack-plugin')

module.exports = {
  mode: 'production',
  entry: { index: path.join(APP_SOURCE, 'ydoc.js') },
  output: {
    path: path.join(__dirname, 'app/lib/ydoc'),
    filename: 'compiler.js',
    libraryTarget: 'umd',
    globalObject: 'this'
  },
  optimization: {
    minimize: true,
    minimizer: [new TerserPlugin({ extractComments: false })]
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        use: 'babel-loader'
      }
    ]
  }
}
