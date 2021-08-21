// @flow

import { LitElement, customElement, html } from 'lit'

import Dialog from '../../helpers/dialog'

export default class DialogOpener extends LitElement {
  static get properties() {
    return {
      target: { type: String }
    }
  }

  async connectedCallback() {
    await super.connectedCallback()

    this.dialogElement = document.getElementById(this.target)
    if (!this.dialogElement) return

    this.dialog = new Dialog(this.dialogElement)
    this.addEventListener('click', this.open)

    this.dialogElement
      .querySelector('svg-icon')
      .addEventListener('click', this.close)
  }

  open = (e: MouseEvent) => {
    e.preventDefault()
    this.dialog.show()
  }

  close = (e: MouseEvent) => {
    this.dialog.hide()
  }

  createRenderRoot() {
    return this
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('dialog-opener')) {
    customElements.define('dialog-opener', DialogOpener)
  }
})
