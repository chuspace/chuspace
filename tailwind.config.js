module.exports = {
  mode: 'jit',
  // These paths are just examples, customize them to match your project structure
  purge: [
    './app/views/**/*.*.erb',
    './app/components/**/*.html.erb',
    './app/components/**/*.rb',
    './app/helpers/**/*.rb',
    './config/initializers/simple_form.rb',
    './app/packs/**/*.js'
  ],

  theme: {
    container: {
      center: true,
      padding: '1rem'
    },
    screens: {
      sm: '576px',
      md: '768px',
      lg: '992px',
      xl: '1160px'
    },
    colors: {
      github: {
        light: '#151413',
        dark: '#111827'
      },
      gitlab: {
        light: '#e65528',
        dark: '#c43f17'
      },
      bitbucket: {
        light: '#0047b3',
        dark: '#003380'
      }
    }
  },
  variants: {
    extend: {}
  },
  plugins: [require('daisyui')],
  daisyui: {
    themes: [
      {
        light: {
          primary: '#111827' /* Primary color */,
          'primary-focus': '#1F2937' /* Primary color - focused */,
          'primary-content':
            '#fff' /* Foreground content color to use on primary color */,

          secondary: '#4B5563' /* Secondary color */,
          'secondary-focus': '#374151' /* Secondary color - focused */,
          'secondary-content':
            '#ffffff' /* Foreground content color to use on secondary color */,

          accent: '#525252' /* Accent color */,
          'accent-focus': '#D97706' /* Accent color - focused */,
          'accent-content':
            '#111827' /* Foreground content color to use on accent color */,

          neutral: '#fff' /* Neutral color */,
          'neutral-focus': '#f4f4f4' /* Neutral color - focused */,
          'neutral-content':
            '#111827' /* Foreground content color to use on neutral color */,

          'base-100':
            '#fff' /* Base color of page, used for blank backgrounds */,
          'base-200': '#ccc' /* Base color, a little darker */,
          'base-300': '#ddd' /* Base color, even more darker */,
          'base-content':
            '#111827' /* Foreground content color to use on base color */,

          info: '#2094f3' /* Info */,
          success: '#009485' /* Success */,
          warning: '#ff9900' /* Warning */,
          error: '#ff5724' /* Error */
        },
        dark: {
          primary: '#3B82F6' /* Primary color */,
          'primary-focus': '#2563EB' /* Primary color - focused */,
          'primary-content':
            '#ffffff' /* Foreground content color to use on primary color */,

          secondary: '#9CA3AF' /* Secondary color */,
          'secondary-focus': '#6B7280' /* Secondary color - focused */,
          'secondary-content':
            '#ffffff' /* Foreground content color to use on secondary color */,

          accent: '#91A6BA' /* Accent color */,
          'accent-focus': '#D97706' /* Accent color - focused */,
          'accent-content':
            '#111827' /* Foreground content color to use on accent color */,

          neutral: '#fff' /* Neutral color */,
          'neutral-focus': '#f4f4f4' /* Neutral color - focused */,
          'neutral-content':
            '#111827' /* Foreground content color to use on neutral color */,

          'base-100':
            '#111827' /* Base color of page, used for blank backgrounds */,
          'base-200': '#585d68' /* Base color, a little darker */,
          'base-300': '#a0a3a9' /* Base color, even more darker */,
          'base-content':
            '#f4f4f4' /* Foreground content color to use on base color */,
          info: '#2094f3' /* Info */,
          success: '#009485' /* Success */,
          warning: '#ff9900' /* Warning */,
          error: '#ff5724' /* Error */
        }
      }
    ]
  }
}
