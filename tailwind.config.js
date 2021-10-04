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
  darkMode: 'media',
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
    borderColor: (theme) => ({
      ...theme('colors'),
      DEFAULT: theme('colors.light', 'currentColor')
    }),
    colors: {
      transparent: 'transparent',
      black: '#111',
      white: '#fff',
      prime: {
        100: '#f4f4f1',
        200: '#e8e9e2',
        300: '#989a7e',
        400: '#464738',
        500: '#2a2b22'
      },

      accent: {
        100: '#f0eef6',
        200: '#dbd6f5',
        300: '#8067fe',
        400: '#3617cf',
        500: '#2e1f7a'
      },

      warn: {
        100: '#f7f4d4',
        200: '#e6df99',
        300: '#e4d101',
        400: '#8a800f',
        500: '#524d14'
      },

      danger: {
        100: '#fcf2e8',
        200: '#efd5be',
        300: '#fe9934',
        400: '#8a0f0f',
        500: '#661a1a'
      },

      success: {
        100: '#eef9ec',
        200: '#dbf5d6',
        300: '#2bfe01',
        400: '#388a0f',
        500: '#335214'
      },

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
      }
    },
    extend: {
      fontFamily: {
        sans: [
          '-apple-system',
          'BlinkMacSystemFont',
          'Segoe UI',
          'Roboto',
          'Helvetica',
          'Arial',
          'sans-serif'
        ],
        serif: [
          'Constantia',
          'Lucida Bright',
          'Lucidabright',
          'Lucida Serif',
          'Lucida',
          'DejaVu Serif',
          'Georgia',
          'Palatino Linotype',
          'Palatino',
          'serif'
        ],
        mono: [
          'DejaVu sans mono',
          'Anonymous Pro',
          'Ubuntu Mono',
          'Droid Sans Mono Consolas',
          'Andale Mono',
          'Consolas',
          'Monaco',
          'Courier New',
          'monospace'
        ]
      }
    }
  },
  variants: {
    extend: {}
  },
  plugins: [require('@tailwindcss/typography')]
}
