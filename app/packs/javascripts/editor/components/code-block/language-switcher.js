// @flow

import { LANGUAGE_MODE_HASH, MODES } from 'editor/modes'
import { LitElement, customElement, html } from 'lit-element'

import type { ModeType } from 'editor/modes/modes'
import autoComplete from '@tarekraafat/autocomplete.js'
import classNames from 'classnames'

export default class LanguageSwitcher extends LitElement {
  static get properties() {
    return {
      mode: { type: String, reflect: true },
      setMode: { type: Function }
    }
  }

  async connectedCallback() {
    await super.connectedCallback()
    this.initAutocomplete()
  }

  get input() {
    return this.querySelector('input')
  }

  initAutocomplete = () => {
    if (this.autocompleteInstance) return

    this.autocompleteInstance = new autoComplete({
      data: {
        src: MODES,
        key: ['name'],
        cache: false
      },
      placeHolder: 'Select language',
      selector: () => this.input,
      threshold: 0,
      debounce: 300,
      searchEngine: 'strict',
      maxResults: 5,
      highlight: true,
      resultsList: {
        render: true,
        container: function(source) {
          source.removeAttribute('id')
          source.className = 'code-editor-language-switcher arrow'
        },
        destination: this.querySelector('.code-editor-language-switcher-container '),
        position: 'beforeend',
        element: 'ul'
      },
      resultItem: {
        content: function(data, source) {
          source.innerHTML = data.match
          source.removeAttribute('id')
        },
        element: 'li'
      },
      onSelection: feedback => this.add(feedback.selection.value)
    })
  }

  add = (language: ModeType) => {
    this.mode = language.mode
    this.input.value = language.name
    this.setMode(this.mode)
  }

  createRenderRoot() {
    return this
  }

  render() {
    const { name } = LANGUAGE_MODE_HASH[this.mode]

    return html`
      <div class="code-editor-language-switcher-container mr-4">
        <input type="text" value=${name} class="input input--slim w-full" />
      </div>
    `
  }
}

document.addEventListener('turbolinks:load', () => {
  if (!window.customElements.get('code-editor-language-switcher')) {
    customElements.define('code-editor-language-switcher', LanguageSwitcher)
  }
})
