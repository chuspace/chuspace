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

      black: '#111',
      white: '#fff',

      github: {
        light: '#151413',
        dark: '#000'
      },
      gitlab: {
        light: '#e65528',
        dark: '#c43f17'
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

      'blue-darkest': '#000099',
      'blue-darker': '#0000bf',
      'blue-dark': '#0000e6',
      blue: '#0000FF',
      'blue-light': '#4d4dff',
      'blue-lighter': '#9999ff',
      'blue-lightest': '#bfbfff',

      'green-darkest': '#0f2f21',
      'green-darker': '#1a4731',
      'green-dark': '#1f9d55',
      green: '#38c172',
      'green-light': '#51d88a',
      'green-lighter': '#a2f5bf',
      'green-lightest': '#e3fcec'
    },
    fontFamily: {
      monospace: ['Space Mono', 'monospace'],
      sans: [
        'Work Sans',
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
