import '@github/details-menu-element'
import '@github/auto-complete-element'
import '@github/tab-container-element'
import '@github/auto-check-element'
import 'core-js/es'
import 'regenerator-runtime/runtime'
import 'lazysizes/plugins/blur-up/ls.blur-up'
import 'lazysizes/plugins/parent-fit/ls.parent-fit'
import '@hotwired/turbo-rails'
import 'dialog-polyfill/dialog-polyfill.css'

import lazySizes from 'lazysizes'

lazySizes.cfg.lazyClass = 'lazy'
lazySizes.cfg.blurupMode = 'auto'

function importAll(r) {
  r.keys().forEach(r)
}

if (
  window.matchMedia &&
  window.matchMedia('(prefers-color-scheme: dark)').matches
) {
  window.colorScheme = 'dark'
} else {
  window.colorScheme = 'light'
}

window
  .matchMedia('(prefers-color-scheme: dark)')
  .addEventListener('change', (e) => {
    window.colorScheme = e.matches ? 'dark' : 'light'
  })

importAll(require.context('../javascripts/elements', true, /.(ts)$/))
