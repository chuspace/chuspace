// @flow

import * as Rails from '@rails/ujs'

import { LitElement, html, svg } from 'lit'

export default class LazyImage extends LitElement {
  static get properties() {
    return {
      src: { type: String },
      alt: { type: String },
      title: { type: String },
      filename: { type: String },
      editable: { type: Boolean },
      rounded: { type: Boolean },
    }
  }

  connectedCallback() {
    super.connectedCallback()

    this.alt = this.alt || ''
    this.title = this.title || ''

    if (this.handleChange) this.setAttribute('editable', true)
  }

  createRenderRoot() {
    return this
  }

  onCaptionChange = (e: Event) => {
    // $FlowFixMe
    this.alt = e.target.value
    this.editable && this.handleChange({ alt: this.alt })
  }

  delete = (e: Event) => {
    this.handleDelete()
  }

  render() {
    return html`
      <figure class="relative">
        ${
          this.editable
            ? svg`
                <div class="bg-base-200 border-b border-base-200 flex items-center justify-between py-3 px-4 rounded-t-md" contenteditable="false">
                  <svg contenteditable="false" xmlns="http://www.w3.org/2000/svg" width="54" height="14" viewBox="0 0 54 14">
                    <g fill="none" fillRule="evenodd" transform="translate(1 1)">
                      <circle cx="6" cy="6" r="6" fill="#FF5F56" stroke="#E0443E" strokeWidth=".5" @click=${this.delete} />
                      <circle cx="26" cy="6" r="6" fill="#FFBD2E" stroke="#DEA123" strokeWidth=".5" />
                      <circle cx="46" cy="6" r="6" fill="#27C93F" stroke="#1AAB29" strokeWidth=".5" />
                    </g>
                  </svg>
                </div>
              `
            : null
        }
        <img alt=${this.alt} width='100%' data-src="${this.src}" title="${
      this.title
    }" data-sizes="auto" class="lazy blur-up${this.rounded ? ' rounded-full' : ''}" />
        ${
          this.editable
            ? html`
                <figcaption contentEditable="false">
                  <input
                    type="text"
                    @change=${this.onCaptionChange}
                    class="input input-sm text-secondary border-t border-base-200 bg-base-200 rounded-tr-none focus:shadow-none rounded-tl-none border-0 w-full p-0 italic text-center text-sm"
                    value=${this.alt}
                    maxlength=${70}
                    placeholder="Click to enter caption (optional)"
                  />
                </figcaption>
              `
            : this.alt
            ? html`
                <figcaption class="w-full mt-2 text-secondary p-0 italic text-center text-sm pb-2">
                  ${this.alt}
                </figcaption>
              `
            : null
        }
        </figcaption>
      </figure>
    `
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('lazy-image')) {
    customElements.define('lazy-image', LazyImage)
  }
})
