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
  darkMode: 'class',
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
      transparent: 'transparent',

      black: '#000',
      white: '#fff',

      github: {
        light: '#151413',
        dark: '#000'
      },
      gitlab: {
        light: '#e65528',
        dark: '#c43f17'
      },
      bitbucket: {
        light: '#0047b3',
        dark: '#003380'
      },
      email: {
        light: 'rgba(0,0,0,0.6)',
        dark: 'rgba(0,0,0,0.8)'
      },
      gray: {
        default: 'rgba(0,0,0,0.8)',
        800: 'rgba(0,0,0,0.8)',
        600: 'rgba(0,0,0,0.6)',
        400: 'rgba(0,0,0,0.4)',
        200: 'rgba(0,0,0,0.2)',
        100: 'rgba(0,0,0,0.1)'
      },

      'red-darkest': '#3b0d0c',
      'red-darker': '#621b18',
      'red-dark': '#cc1f1a',
      red: '#e3342f',
      'red-light': '#ef5753',
      'red-lighter': '#f9acaa',
      'red-lightest': '#fcebea',

      'blue-darkest': '#004180',
      'blue-darker': '#005ab3',
      'blue-dark': '#0074e6',
      blue: '#1089ff',
      'blue-light': '#4da7ff',
      'blue-lighter': '#80c0ff',
      'blue-lightest': '#b3d9ff',

      'green-darkest': '#0f2f21',
      'green-darker': '#1a4731',
      'green-dark': '#1f9d55',
      green: '#38c172',
      'green-light': '#51d88a',
      'green-lighter': '#a2f5bf',
      'green-lightest': '#e3fcec'
    },
    fontFamily: {
      sans: [
        'Inter',
        'system-ui',
        'BlinkMacSystemFont',
        '-apple-system',
        'Segoe UI',
        'Roboto',
        'Oxygen',
        'Ubuntu',
        'Cantarell',
        'Open Sans',
        'Fira Sans',
        'Droid Sans',
        'Helvetica Neue',
        'sans-serif'
      ],
      serif: [
        'Source Serif Pro',
        'Lucida Grande',
        'Lucida Sans Unicode',
        'Lucida Sans',
        'Tahoma',
        'Verdana',
        'Arial',
        'Geneva',
        'Georgia',
        'sans-serif'
      ],
      mono: [
        'Fira Code',
        'Menlo',
        'Monaco',
        'Consolas',
        'Liberation Mono',
        'Courier New',
        'monospace'
      ]
    }
  },
  variants: {
    extend: {}
  },
  plugins: [require('@tailwindcss/typography')]
}
