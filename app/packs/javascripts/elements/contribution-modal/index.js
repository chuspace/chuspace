// @flow

import { LitElement, html, svg } from 'lit'
import { createRef, ref } from 'lit/directives/ref.js'

import Controls from 'editor/components/code-block/controls'
import Dialog from 'helpers/dialog'
import { Node } from 'editor/base'

export default class ContributionModal extends LitElement {
  static properties = {
    contribution: { type: Object },
    content: { type: String },
    diffMode: { type: Boolean }
  }

  inputRef = createRef()

  constructor() {
    super()

    this.content = null
    this.editor = null
    this.diffMode = false
  }

  firstUpdated() {
    this.dialog = new Dialog(this.querySelector('dialog'))
    this.commitMessageInput = this.inputRef.value
  }

  onEditorInit = (editor) => (this.editor = editor)

  createRenderRoot() {
    return this
  }

  onChange = () => (this.content = this.editor.content)

  handleSave = (event) => {
    event.preventDefault()

    this.dialog.hide()
    this.remove()

    this.contribution.handleAdd(event, {
      ...this.contribution,
      content: this.editor.content,
      yDocBase64: this.editor.toYDocBase64
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

  toggleDiff = (event) => {
    event.preventDefault()
    this.diffMode = !this.diffMode
  }

  get isStale() {
    if (this.diffMode) {
      return true
    } else {
      return this.content && this.content !== this.contribution.content
    }
  }

  renderNode = () =>
    this.contribution.node.type === 'code_block'
      ? this.renderCodeEditor()
      : this.renderNodeEditor()

  renderCodeEditor = () =>
    html`
      <code-editor
        class="chu-editor"
        contribution
        ?diff=${this.diffMode}
        mode=${this.contribution.node.meta.lang}
        wrapper="false"
        content=${this.contribution.content}
        .onChange=${this.onChange}
        .onEditorInit=${this.onEditorInit}
      ></code-editor>
    `

  renderNodeEditor = () =>
    html`
      <div class="card-body overflow-y-scroll">
        <node-editor
          ?autoFocus=${!this.diffMode}
          ?editable=${!this.diffMode}
          ?diff=${this.diffMode}
          nodeName=${this.contribution.node.type}
          .author=${this.contribution.author}
          .onChange=${this.onChange}
          .onEditorInit=${this.onEditorInit}
          .commits=${this.contribution.commits}
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
        open
        class="p-0 fixed top-1/2 transform -translate-y-1/2 border-0 bg-transparent sm:w-1/2 w-full sm:mx-auto z-50"
      >
        <div class="card border border-base-300 bg-base-200 h-96">
          <div
            class="font-mono bg-base-300 text-base p-2 px-4  flex items-center justify-between"
          >
            <span>${`Edit ${this.contribution.node.type}`}</span>
            <span class="badge badge-warning">Suggestion</span>
            ${this.isStale
              ? this.diffMode
                ? html`
                    <a @click=${this.toggleDiff}>Hide Diff</a>
                  `
                : html`
                    <a @click=${this.toggleDiff}>Show Diff</a>
                  `
              : null}
            ${svg`<svg @click=${this.handleClose} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24"><path fill-rule="evenodd" d="M5.72 5.72a.75.75 0 011.06 0L12 10.94l5.22-5.22a.75.75 0 111.06 1.06L13.06 12l5.22 5.22a.75.75 0 11-1.06 1.06L12 13.06l-5.22 5.22a.75.75 0 01-1.06-1.06L10.94 12 5.72 6.78a.75.75 0 010-1.06z"></path></svg>`}
          </div>
          ${this.renderNode()}
          <div
            class="card-actions bg-base-200 absolute bottom-0 w-full border-t border-base-300 px-4 py-2 flex justify-end"
          >
            <input
              ${ref(this.inputRef)}
              class="input input-bordered input-sm"
              placeholder="Commit message"
              ?disabled=${!this.isStale}
            />
            ${this.contribution.id
              ? html`
                  <button
                    @click=${this.handleRemove}
                    class="btn btn-outline btn-error btn-sm"
                  >
                    Remove
                  </button>
                `
              : null}

            <button
              @click=${this.handleSave}
              class="btn btn-primary btn-sm"
              ?disabled=${!this.isStale}
            >
              ${this.contribution.id ? 'Update' : 'Add'}
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
