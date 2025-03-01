// @flow

import { LitElement, html } from 'lit'

import ClipboardJS from 'clipboard'
import tippy from 'tippy.js'

const SVG_RATIO = 0.81

export default class CopyClipboard extends LitElement {
  static get properties() {
    return {
      initClipboardJS: { type: Function },
    }
  }

  async connectedCallback() {
    await super.connectedCallback()

    if (this.initClipboardJS) {
      this.initClipboardJS(this)
    } else {
      const clipboard = new ClipboardJS(this)

      clipboard.on('success', (e) => {
        const instance = tippy(this, {
          arrow: true,
          showOnCreate: true,
          trigger: 'click',
          content: 'Copied',
        })

        setTimeout(() => {
          instance.destroy()
        }, 1000)
      })
    }
  }

  createRenderRoot() {
    return this
  }

  render() {
    const width = SVG_RATIO * 16

    return html`
      <svg
        contenteditable="false"
        class="cursor-pointer block fill-current"
        width=${width}
        height="16"
        viewBox="0 0 13 16"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          d="M8 0H3.40385C2.55385 0 1.84615 0.669231 1.84615 1.51923V1.84615H1.55769C0.707692 1.84615 0 2.51538 0 3.36538V14.4423C0 15.2923 0.707692 16 1.55769 16H9.55769C10.4077 16 11.0769 15.2923 11.0769 14.4423V14.1538H11.4038C12.2538 14.1538 12.9231 13.4462 12.9231 12.5962V4.92308L8 0ZM8 1.71538L11.2077 4.92308H8V1.71538ZM9.84615 14.4423C9.84615 14.6231 9.71538 14.7692 9.55769 14.7692H1.55769C1.38846 14.7692 1.23077 14.6115 1.23077 14.4423V3.36538C1.23077 3.20769 1.37692 3.07692 1.55769 3.07692H1.84615V12.9038C1.84615 13.7538 2.24615 14.1538 3.09615 14.1538H9.84615V14.4423ZM11.6923 12.5962C11.6923 12.7769 11.5615 12.9231 11.4038 12.9231H3.40385C3.23462 12.9231 3.07692 12.7654 3.07692 12.5962V1.51923C3.07692 1.36154 3.22308 1.23077 3.40385 1.23077H6.76923V6.15385H11.6923V12.5962Z"
        />
      </svg>
    `
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('copy-clipboard')) {
    customElements.define('copy-clipboard', CopyClipboard)
  }
})
