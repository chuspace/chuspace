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
  daisyui: {
    themes: ['light', 'dark']
  },
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
      prime: {
        100: '#f4f4f1',
        200: '#e8e9e2',
        300: '#989a7e',
        400: '#464738',
        500: '#2a2b22'
      },

      accent: {
        100: '#EFF6FF',
        200: '#93C5FD',
        300: '#60A5FA',
        400: '#3B82F6',
        500: '#2563EB'
      },

      warn: {
        100: '#FFFBEB',
        200: '#FCD34D',
        300: '#e4d101',
        400: '#FBBF24',
        500: '#F59E0B'
      },

      danger: {
        100: '#FEF2F2',
        200: '#FCA5A5',
        300: '#F87171',
        400: '#EF4444',
        500: '#DC2626'
      },

      success: {
        100: '#ECFDF5',
        200: '#6EE7B7',
        300: '#34D399',
        400: '#10B981',
        500: '#059669'
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
  plugins: [require('@tailwindcss/typography'), require('daisyui')]
}
