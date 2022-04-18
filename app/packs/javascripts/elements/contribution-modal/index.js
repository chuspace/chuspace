// @flow

import { LitElement, html, svg } from 'lit'

import Controls from 'editor/components/code-block/controls'
import Dialog from 'helpers/dialog'
import { Node } from 'editor/base'

export default class ContributionModal extends LitElement {
  static properties = {
    contribution: { type: Object },
    content: { type: String }
  }

  constructor() {
    super()

    this.content = null
  }

  firstUpdated() {
    this.dialog = new Dialog(this.querySelector('dialog'))
    this.dialog.show()
  }

  createRenderRoot() {
    return this
  }

  setValue = (content) => {
    this.contribution.content = content
  }

  handleAdd = (event) => {
    event.preventDefault()

    this.dialog.hide()
    this.remove()
    this.contribution.handleAdd(event, {
      ...this.contribution,
      persisted: true
    })
  }

  handleRemove = (event) => {
    event.preventDefault()
    this.contribution.handleRemove(event)
    this.dialog.hide()
    this.remove()
  }

  handleClose = (event) => {
    event.preventDefault()

    this.dialog.hide()
    this.remove()
  }

  get isStale() {
    return this.content && this.content !== this.contribution.content
  }

  renderCodeEditor = () =>
    html`
      <code-editor
        mode=${this.contribution.node.meta.lang}
        wrapper="false"
        .onChange=${this.setValue}
        content=${this.contribution.content}
      ></code-editor>
    `

  renderNodeEditor = () =>
    html`
      <div class="card-body overflow-y-scroll">
        <node-editor
          editable
          autoFocus
          nodeName=${this.contribution.node.type}
          .onChange=${this.setValue}
        >
          <textarea
            class="hidden content"
            .value=${this.contribution.content}
          ></textarea>
        </node-editor>
      </div>
    `

  render() {
    return html`
      <dialog
        class="p-0 fixed top-1/2 transform -translate-y-1/2 border-0 bg-transparent sm:w-1/2 w-full sm:mx-auto z-50"
      >
        <div class="card border border-base-300 bg-base-200 h-96">
          <div
            class="font-mono bg-base-300 text-base p-2 px-4  flex items-center justify-between"
          >
            <span>${`Edit ${this.contribution.node.type}`}</span>
            <span class="badge badge-warning">Suggestion</span>
            ${svg`<svg @click=${this.handleClose} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24"><path fill-rule="evenodd" d="M5.72 5.72a.75.75 0 011.06 0L12 10.94l5.22-5.22a.75.75 0 111.06 1.06L13.06 12l5.22 5.22a.75.75 0 11-1.06 1.06L12 13.06l-5.22 5.22a.75.75 0 01-1.06-1.06L10.94 12 5.72 6.78a.75.75 0 010-1.06z"></path></svg>`}
          </div>

          ${this.contribution.node.type === 'code_block'
            ? this.renderCodeEditor()
            : this.renderNodeEditor()}

          <div
            class="card-actions bg-base-200 absolute bottom-0 w-full border-t border-base-300 px-4 py-2 flex justify-end"
          >
            ${this.contribution.persisted
              ? html`
                  <button
                    @click=${this.handleRemove}
                    class="btn btn-outline btn-error btn-sm"
                  >
                    Remove
                  </button>
                `
              : null}

            <button @click=${this.handleAdd} class="btn btn-primary btn-sm">
              Save
            </button>
          </div>
        </div>
      </dialog>
    `
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('contribution-modal')) {
    customElements.define('contribution-modal', ContributionModal)
  }
})
