import '@github/details-menu-element'
import '@github/auto-complete-element'
import '@github/tab-container-element'
import '@github/auto-check-element'
import '@github/include-fragment-element'
import '@github/clipboard-copy-element'
import '@github/image-crop-element'
import '@github/time-elements'
import 'details-element-polyfill'
import 'core-js/es'
import 'regenerator-runtime/runtime'
import 'lazysizes/plugins/blur-up/ls.blur-up'
import 'lazysizes/plugins/parent-fit/ls.parent-fit'
import 'lazysizes/plugins/respimg/ls.respimg'
import '@hotwired/turbo-rails'
import 'dialog-polyfill/dialog-polyfill.css'
import '@github/g-emoji-element'
import 'editor'
import 'editor/styles.sass'

import autosize from '@github/textarea-autosize'
import lazySizes from 'lazysizes'

if (!('object-fit' in document.createElement('a').style)) {
  import('lazysizes/plugins/object-fit/ls.object-fit')
}

lazySizes.cfg.lazyClass = 'lazy'
lazySizes.cfg.blurupMode = 'auto'

function importAll(r) {
  r.keys().forEach(r)
}

if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
  window.colorScheme = 'dark'
} else {
  window.colorScheme = 'light'
}

window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
  window.colorScheme = e.matches ? 'dark' : 'light'
})

importAll(require.context('../javascripts/elements', true, /.(ts)$/))

document.addEventListener('turbo:load', () => {
  document.querySelectorAll('textarea.autosize').forEach(autosize)
})
