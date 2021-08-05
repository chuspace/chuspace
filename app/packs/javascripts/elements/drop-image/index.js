// @flow

import { LitElement, customElement, html } from 'lit-element'

const ACCEPTED_IMAGES = ['image/png', 'image/jpg', 'image/jpeg', 'image/gif']

export default class DropImage extends LitElement {
  static get properties() {
    return {
      hint: { type: String },
      errors: { type: String },
      param: { type: String }
    }
  }

  async connectedCallback() {
    await super.connectedCallback()

    this.input = this.querySelector('#drop_input')
    this.input.classList.add('hidden')

    this.addEventListener('click', this.handleClick)
    this.addEventListener('dragover', this.handleDrag)
    this.addEventListener('drop', this.handleDrop)
    this.input.addEventListener('change', this.handleChange)
  }

  disconnectedCallback() {
    super.disconnectedCallback()

    this.removeEventListener('click', this.handleClick)
    this.removeEventListener('dragover', this.handleDrag)
    this.removeEventListener('drop', this.handleDrop)
    this.input.removeEventListener('change', this.handleChange)
  }

  handleDrag = (event: Event) => event.preventDefault()

  handleDrop = (event: DropImage) => {
    event.preventDefault()

    const image = event.dataTransfer.files[0]
    this.insert(image)
    this.input.files = event.dataTransfer.files
  }

  handleChange = (event: Event) => {
    /* $FlowFixMe */
    const image = event.target.files[0]
    this.insert(image)
  }

  insert = (image: File) => {
    if (ACCEPTED_IMAGES.includes(image.type)) {
      const reader = new FileReader()

      reader.readAsDataURL(image)
      reader.onload = (file) => {
        const image = this.querySelector('img')
        /* $FlowFixMe */
        image.src = file.target.result
      }
    }
  }

  handleClick = () => this.input.click()

  createRenderRoot() {
    return this
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('drop-image')) {
    customElements.define('drop-image', DropImage)
  }
})
