// @flow

import { LitElement, html } from 'lit'

import Codemirror from 'editor/codemirror'
import Fuse from 'fuse.js'
import classNames from 'classnames'
import debounce from 'lodash.debounce'
import { repeat } from 'lit/directives/repeat.js'

export default class LanguageSwitcher extends LitElement {
  static get properties() {
    return {
      mode: { type: String, reflect: true },
      items: { type: Array },
      open: { type: Boolean },
      setMode: { type: Function },
    }
  }

  connectedCallback() {
    super.connectedCallback()
    this.initFuse()

    this.close()
  }

  initFuse = async () => {
    if (this.fuse) return

    const options = {
      includeScore: true,
      keys: ['name', 'mode'],
    }

    this.fuse = new Fuse(CodeMirror.modeInfo, options)
  }

  firstUpdated() {
    this.input = this.renderRoot.querySelector('input')
  }

  select = (event: Event, mode: ModeType) => {
    event.preventDefault()

    this.mode = mode.name
    this.input.value = this.mode
    this.setMode(this.mode)
    this.close()
  }

  createRenderRoot() {
    return this
  }

  searchModes = debounce((event: Event) => {
    if (event.target.value) {
      this.items = this.fuse.search(event.target.value).map((item) => item.item)
      this.show()
    } else {
      this.close()
    }
  }, 200)

  show = () => (this.open = true)
  close = () => {
    this.open = false
    this.items = CodeMirror.modeInfo
  }

  render() {
    return html`
      <div class="code-editor-language-switcher-container mr-4">
        <div class="dropdown dropdown-end">
          <input
            type="text"
            placeholder="Type to search..."
            value=${this.mode}
            class="input input-sm w-full max-w-xs"
            @input=${this.searchModes}
            @focus=${this.show}
            @blur=${this.hide}
          />
          ${this.open
            ? html`<ul
                class="shadow menu dropdown-content absolute z-10 bg-base-100 border border-base-100 rounded-box w-52 h-48 overflow-y-scroll"
              >
                ${repeat(
                  this.items,
                  (item) => item.name,
                  (item) =>
                    html`<button
                      role="option"
                      class="border-b p-2 text-left border-base-200 py-2 px-4 cursor-pointer last:border-b-0"
                      id="${item.id}"
                      @click="${(event) => this.select(event, item)}"
                    >
                      ${item.name}
                    </button>`
                )}
              </ul>`
            : null}
        </div>
      </div>
    `
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('code-editor-language-switcher')) {
    customElements.define('code-editor-language-switcher', LanguageSwitcher)
  }
})
