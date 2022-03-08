// @flow

import { LitElement, html, svg } from 'lit'
import Controls from 'editor/components/code-block/controls'

export default class ContributionModal extends LitElement {
  static properties = {
    nodeName: { type: String },
    content: { type: String },
    newContent: { type: String },
    state: { type: String, reflect: true },
    onSubmit: { type: Function },
    onStateChange: { type: Function }
  }

  constructor() {
    super()

    this.nodeName = 'paragraph'
    this.state = 'closed'
  }

  createRenderRoot() {
    return this
  }

  handleOpen = () => {
    this.state = 'open'
    this.onStateChange(this.state)
  }

  handleClose = () => {
    this.state = 'closed'
    this.onStateChange(false)
  }

  setValue = (content) => {
    if (this.content === content) this.newContent = null
    else this.newContent = content
  }

  handleSubmit = (event) => {
    event.preventDefault()

    this.onSubmit(this.newContent)
    this.handleClose()
  }

  get isOpen() {
    return this.state === 'open'
  }

  get isStale() {
    return this.newContent && this.newConten !== this.content
  }

  render() {
    const icon = svg`<svg xmlns="http://www.w3.org/2000/svg" @click=${this.handleOpen} viewBox="0 0 24 24"><path fill-rule="evenodd" d="M11.75 4.5a.75.75 0 01.75.75V11h5.75a.75.75 0 010 1.5H12.5v5.75a.75.75 0 01-1.5 0V12.5H5.25a.75.75 0 010-1.5H11V5.25a.75.75 0 01.75-.75z"></path></svg>`

    return this.isOpen
      ? html`
          <div class="card border border-base-300 bg-base-200 mt-4">
            <div
              class="border-b text-sm border-base-300 px-4 py-2 flex justify-between"
            >
              ${Controls({ destroy: this.handleClose })}
              <span>Editing ${this.nodeName}</span>
              <span class="badge badge-warning">Suggestion</span>
            </div>
            <div class="card-body">
              <chu-editor
                class="chu-editor"
                mode="node"
                nodeName=${this.nodeName}
                .onChange=${this.setValue}
              >
                <textarea
                  class="hidden content"
                  .value=${this.content}
                ></textarea>
              </chu-editor>
            </div>

            <div
              class="card-actions border-t border-base-300 px-4 py-2 flex justify-end"
            >
              <button
                @click=${this.handleSubmit}
                class="btn btn-outline btn-sm"
                ?disabled=${!this.isStale}
              >
                Submit
              </button>
            </div>
          </div>
        `
      : html`
          <span
            class="fill-current w-6 h-6 absolute -left-12 inset-y-1/2 mr-12 -translate-y-1/2 bg-success flex items-center justify-center rounded"
          >
            ${icon}
          </span>
        `
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('contribution-modal')) {
    customElements.define('contribution-modal', ContributionModal)
  }
})
