// @flow

import { LitElement, customElement, html } from 'lit'

export default class AlertNotification extends LitElement {
  static get properties() {
    return {
      level: { type: String },
      message: { type: String }
    }
  }

  connectedCallback() {
    super.connectedCallback()

    setTimeout(this.hide, 5000)
  }

  createRenderRoot() {
    return this
  }

  hide = () => {
    this.classList.remove('fadeInDown')
    this.classList.add('fadeOutUp')
  }

  render() {
    return html`
      <div class="alert alert--${this.level}" @click=${this.hide}>
        <div class="p-4 ">${this.message}</div>
      </div>
    `
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('alert-notification')) {
    customElements.define('alert-notification', AlertNotification)
  }
})
