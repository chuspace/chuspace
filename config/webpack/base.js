const { webpackConfig, mergeWithRules } = require('@rails/webpacker')
const sassRule = require('@rails/webpacker/package/rules/sass')
const globImporter = require('node-sass-glob-importer')

sassRule.use[3] = Object.assign({}, sassRule.use[3], {
  options: {
    sassOptions: {
      importer: globImporter()
    }
  }
})

const appWebpackConfig = {
  name: 'chuspace',
  stats: 'minimal',
  devtool: 'none',
  performance: {
    hints: false
  },
  resolve: {
    fallback: {
      assert: false
    }
  },
  module: {
    rules: [sassRule]
  }
}

module.exports = mergeWithRules({
  module: {
    rules: {
      test: 'match',
      use: 'replace'
    }
  }
})(appWebpackConfig, webpackConfig)
