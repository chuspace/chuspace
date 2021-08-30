const { moduleExists } = require('@rails/webpacker')

module.exports = function config(api) {
  const validEnv = ['development', 'test', 'production']
  const currentEnv = api.env()
  const isDevelopmentEnv = api.env('development')
  const isProductionEnv = api.env('production')
  const isTestEnv = api.env('test')

  if (!validEnv.includes(currentEnv)) {
    throw new Error(
      `Please specify a valid NODE_ENV or BABEL_ENV environment variable. Valid values are "development", "test", and "production". Instead, received: "${JSON.stringify(
        currentEnv
      )}".`
    )
  }

  return {
    presets: [
      isTestEnv && ['@babel/preset-env', { targets: { node: 'current' } }],
      (isProductionEnv || isDevelopmentEnv) && [
        '@babel/preset-env',
        {
          useBuiltIns: 'entry',
          corejs: '3.8',
          modules: 'auto',
          bugfixes: true,
          loose: true,
          exclude: ['transform-typeof-symbol']
        }
      ],
      '@babel/preset-flow'
    ].filter(Boolean),
    plugins: [
      ['@babel/plugin-proposal-decorators', { legacy: true }],
      ['@babel/plugin-proposal-class-properties', { loose: true }],
      ['@babel/plugin-transform-runtime', { helpers: false }],
      [
        require('babel-plugin-module-resolver').default,
        {
          root: ['./app/packs'],
          alias: {
            controllers: './app/packs/javascripts/controllers',
            helpers: './app/packs/javascripts/helpers',
            decorators: './app/packs/javascripts/decorators',
            styles: './app/packs/stylesheets',
            editor: './app/packs/javascripts/editor',
            elements: './app/packs/javascripts/elements'
          }
        }
      ]
    ].filter(Boolean)
  }
}
