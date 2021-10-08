// @flow

import * as Rails from '@rails/ujs'

import { LitElement, html, svg } from 'lit'

export default class LazyImage extends LitElement {
  static get properties() {
    return {
      src: { type: String },
      alt: { type: String },
      title: { type: String },
      editable: { type: Boolean }
    }
  }

  connectedCallback() {
    super.connectedCallback()

    try {
      this.alt = JSON.parse(this.alt) || ''
      this.title = JSON.parse(this.title) || ''
    } catch (e) {}

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
      <figure class="image__container">
        ${
          this.editable
            ? svg`
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 16 16"
                  width="16"
                  height="16"
                  @click=${this.delete}
                  class="absolute close right-0 cursor-pointer bg-primary p-2 shadow-md"
                >
                  <path
                    fill-rule="evenodd"
                    d="M2.343 13.657A8 8 0 1113.657 2.343 8 8 0 012.343 13.657zM6.03 4.97a.75.75 0 00-1.06 1.06L6.94 8 4.97 9.97a.75.75 0 101.06 1.06L8 9.06l1.97 1.97a.75.75 0 101.06-1.06L9.06 8l1.97-1.97a.75.75 0 10-1.06-1.06L8 6.94 6.03 4.97z"
                  ></path>
                </svg>
              `
            : null
        }
        <img alt=${this.alt} data-src="${this.src}" title="${
      this.title
    }" data-sizes="auto" class="lazy blur-up" />
        ${
          this.editable
            ? html`
                <figcaption contentEditable="false">
                  <input
                    type="text"
                    @change=${this.onCaptionChange}
                    class="input input-primary rounded-tr-none focus:shadow-none rounded-tl-none border-0 w-full p-0 italic text-center text-sm"
                    value=${this.alt}
                    maxlength=${70}
                    placeholder="Click to enter caption (optional)"
                  />
                </figcaption>
              `
            : this.alt
            ? html`
                <figcaption>${this.alt}</figcaption>
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
