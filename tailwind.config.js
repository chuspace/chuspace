module.exports = {
  mode: 'jit',
  // These paths are just examples, customize them to match your project structure
  content: [
    './app/views/**/*.*.erb',
    './app/components/**/*.html.erb',
    './app/components/**/*.rb',
    './app/helpers/**/*.rb',
    './config/initializers/simple_form.rb',
    './app/packs/**/*.js',
  ],

  theme: {
    container: {
      center: true,
      padding: '1rem',
    },
    screens: {
      sm: '576px',
      md: '768px',
      lg: '992px',
      xl: '1160px',
    },
    colors: {
      github: {
        light: '#151413',
        dark: '#111827',
      },
      gitea: {
        light: '#87ab63',
        dark: '#528321',
      },
      gitlab: {
        light: '#e65528',
        dark: '#c43f17',
      },
      bitbucket: {
        light: '#0047b3',
        dark: '#003380',
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [require('@tailwindcss/typography'), require('daisyui')],
  daisyui: {
    themes: [
      {
        dark: {
          primary: '#2563EB' /* Primary color */,
          'primary-focus': '#3B82F6' /* Primary color - focused */,
          'primary-content': '#ffffff' /* Foreground content color to use on primary color */,

          secondary: '#8b949e' /* Secondary color */,
          'secondary-focus': '#999999' /* Secondary color - focused */,
          'secondary-content': '#111827' /* Foreground content color to use on secondary color */,

          accent: '#4E9F3D' /* Accent color */,
          'accent-focus': '#468f37' /* Accent color - focused */,
          'accent-content': '#111827' /* Foreground content color to use on accent color */,

          neutral: '#ffffff' /* Neutral color */,
          'neutral-focus': '#f4f4f4' /* Neutral color - focused */,
          'neutral-content': '#111827' /* Foreground content color to use on neutral color */,

          'base-100': '#111827' /* Base color of page, used for blank backgrounds */,
          'base-200': '#1A243B' /* Base color, a little darker */,
          'base-300': '#313a4f' /* Base color, even more darker */,
          'base-content': '#d4d4d4' /* Foreground content color to use on base color */,

          info: '#2094f3' /* Info */,
          success: '#4ade80' /* Success */,
          warning: '#ff9900' /* Warning */,
          error: '#f87171' /* Error */,
        },
      },
    ],
  },
}
