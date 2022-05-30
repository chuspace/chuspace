process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const webpackConfig = require('./base')
const TerserPlugin = require('terser-webpack-plugin')
const { merge } = require('@rails/webpacker')

webpackConfig.optimization.minimizer = webpackConfig.optimization.minimizer.filter(
  (plugin) => plugin.constructor && plugin.constructor.name === 'CssMinimizerPlugin'
)

const productionConfig = {
  optimization: {
    minimizer: [
      new TerserPlugin({
        parallel: Number.parseInt(process.env.WEBPACKER_PARALLEL, 10) || true,
        terserOptions: {
          keep_classnames: /Element$/,
          parse: {
            ecma: 8,
          },
          compress: {
            ecma: 5,
            warnings: false,
            comparisons: false,
          },
          mangle: { safari10: true },
          output: {
            ecma: 5,
            comments: false,
            ascii_only: true,
          },
        },
      }),
    ],
  },
}

module.exports = merge(webpackConfig, productionConfig)
