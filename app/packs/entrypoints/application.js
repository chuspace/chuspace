import '@github/details-menu-element'
import '@github/auto-complete-element'
import '@github/tab-container-element'
import 'core-js/es'
import 'regenerator-runtime/runtime'
import 'lazysizes/plugins/blur-up/ls.blur-up'
import 'lazysizes/plugins/parent-fit/ls.parent-fit'
import '@hotwired/turbo-rails'

import lazySizes from 'lazysizes'

lazySizes.cfg.lazyClass = 'lazy'
lazySizes.cfg.blurupMode = 'auto'

function importAll(r) {
  r.keys().forEach(r)
}

importAll(require.context('../javascripts/elements', true, /.(ts)$/))
importAll(require.context('../../components', true, /.(sass|ts)$/))
