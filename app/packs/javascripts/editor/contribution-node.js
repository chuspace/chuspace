// @flow

import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'
import { Fragment, Schema } from 'prosemirror-model'
import { LitElement, html, svg } from 'lit'
import { NodeSelection, Selection } from 'prosemirror-state'
import { baseKeymap, selectParentNode } from 'prosemirror-commands'
import { createRef, ref } from 'lit/directives/ref.js'
import { history, redo, undo } from 'prosemirror-history'
import { markdownParser, markdownSerializer } from 'editor/markdowner'

import { CodeBlock as CodeBlockComponent } from 'editor/components'
import Dialog from 'helpers/dialog'
import { EditorView } from 'prosemirror-view'
import { MarkdownParser } from 'prosemirror-markdown'
import SchemaManager from 'editor/schema'
import { contributionWidgetKey } from 'editor/plugins/contribution/widget'
import { dropCursor } from 'prosemirror-dropcursor'
import { gapCursor } from 'prosemirror-gapcursor'
import { inputRules } from 'prosemirror-inputrules'
import { keymap } from 'prosemirror-keymap'
import { patch } from '@rails/request.js'
import { randomColor } from 'helpers/random-color'

const DEFAULT_EDITOR_NODES = ['doc', 'text', 'paragraph']

export default class ContributionNodeEditor extends LitElement {
  static properties = {
    contribution: { type: Object },
    parentEditor: { type: Object }
  }

  manager: SchemaManager
  schema: Schema
  contentParser: MarkdownParser
  contentSerializer: contentSerializer
  state: EditorState
  view: EditorView
  dirty: boolean = false
  editorRef = createRef()
  inputRef = createRef()

  constructor() {
    super()
    
    this.mode = 'contribution'
    this.editable = true
    this.open = false
  }

  connectedCallback() {
    super.connectedCallback()

    this.editable = this.contribution.status !== 'open'
    this.open = this.contribution.status === 'open'

    this.manager = new SchemaManager(this, [
      ...DEFAULT_EDITOR_NODES,
      this.contribution.node.type
    ])

    this.schema = this.manager.schema

    this.contentParser = markdownParser(this.schema, true)
    this.contentSerializer = markdownSerializer(this.schema, true)
    this.doc = this.contentParser.parse(
      this.contribution.contentAfter || this.contribution.contentBefore
    )
  }

  firstUpdated() {
    this.dialog = new Dialog(this.querySelector('dialog'))
    this.editorNode = this.editorRef.value
    this.commitMessageInput = this.inputRef.value

    this.state = this.createState()
    this.view = this.createView()

    if (this.autoFocus) this.focus()

    this.dialog.show()
    if (this.editable) this.checkDirty()
  }

  disconnectedCallback() {
    super.disconnectedCallback()

    this.destroy()
  }

  createRenderRoot() {
    return this
  }

  get isNodeEditor() {
    return true
  }

  get isCodeBlock() {
    return this.contribution.node.type === 'code_block'
  }

  get isStale() {
    return this.contribution.contentBefore !== this.contribution.contentAfter
  }

  get plugins() {
    return [
      inputRules({
        rules: this.manager.inputRules
      }),
      ...this.manager.pasteRules,
      ...this.manager.keymaps,
      keymap({
        'Mod-z': undo,
        'Mod-y': redo,
        'Mod-Shift-z': redo,
        ...baseKeymap
      }),

      dropCursor(),
      gapCursor(),

      new Plugin({
        key: new PluginKey('editable'),
        props: {
          editable: () => this.editable
        }
      }),
      new Plugin({
        key: new PluginKey('tabindex'),
        props: {
          attributes: {
            tabindex: 0
          }
        }
      })
    ]
  }

  createState = () =>
    EditorState.create({
      doc: this.doc,
      schema: this.schema,
      plugins: this.plugins
    })

  createView() {
    const view = new EditorView(this.editorNode, {
      state: this.state,
      schema: this.schema,
      editable: () => this.editable,
      dispatchTransaction: this.dispatchTransaction.bind(this),
      nodeViews: this.manager.nodeViews
    })

    view.dom.style.whiteSpace = 'pre-wrap'
    view.dom.title = 'Enter post content'
    view.dom.id = 'editor-content'
    view.dom.classList.add(
      'chu-editor',
      'contribution-node',
      this.editable ? 'editable' : 'read-only'
    )

    return view
  }

  setContribution = () => {
    this.contribution = Object.assign({}, this.contribution, {
      contentAfter: this.content
    })
  }

  dispatchTransaction(transaction: Transaction) {
    this.state = this.state.apply(transaction)
    this.view.updateState(this.state)

    if (transaction.docChanged && this.editable) {
      this.setContribution()
      this.dirty = this.isStale
    }

    return true
  }

  focus() {
    const tr = this.state.tr.setSelection(Selection.atEnd(this.state.doc))
    this.view.dispatch(tr)
    this.view.focus()
  }

  get content() {
    return this.contentSerializer.serialize(this.state.doc)
  }

  handleDialogClose = (event) => {
    event.preventDefault()

    this.destroy()
    this.dialog.hide()
    this.remove()
  }

  handleSave = (event) => {
    event.preventDefault()

    this.setContribution()

    this.parentEditor.addContribution(this.contribution)
    this.handleDialogClose(event)
  }

  handleClose = (event) => {
    event.preventDefault()

    this.parentEditor.closeContribution(this.contribution)
    this.handleDialogClose(event)
  }

  handleRemove = (event) => {
    event.preventDefault()

    this.parentEditor.removeContribution(this.contribution)
    this.handleDialogClose(event)
  }

  handleMerge = (event) => {
    event.preventDefault()

    this.parentEditor.mergeContribution(this.contribution)
    this.handleDialogClose(event)
  }

  render() {
    return html`
      <dialog
        class="p-0 fixed top-1/2 transform -translate-y-1/2 border-0 bg-transparent sm:w-1/2 w-full sm:mx-auto z-50"
      >
        <div class="card border border-base-300 bg-base-200 h-96">
          <div
            class="font-mono bg-base-300 text-base p-2 px-4  flex items-center justify-between"
          >
            <span>Suggestion#${this.contribution.id}</span>
            ${svg`<svg class='cursor-pointer fill-current' @click=${this.handleDialogClose} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24"><path fill-rule="evenodd" d="M5.72 5.72a.75.75 0 011.06 0L12 10.94l5.22-5.22a.75.75 0 111.06 1.06L13.06 12l5.22 5.22a.75.75 0 11-1.06 1.06L12 13.06l-5.22 5.22a.75.75 0 01-1.06-1.06L10.94 12 5.72 6.78a.75.75 0 010-1.06z"></path></svg>`}
          </div>
          <div
            class="card-body overflow-y-scroll${this.isCodeBlock
              ? ' px-0 py-0'
              : ''}"
            ${ref(this.editorRef)}
          ></div>
          <div
            class="card-actions bg-base-200 absolute bottom-0 w-full border-t border-base-300 px-4 py-2 flex justify-between"
          >
            <div class="flex items-center">
              <div class="avatar">
                <div class="w-8 rounded-full">
                  <img src="${this.contribution.author.avatar_url}" />
                </div>
              </div>
              <h5 class="ml-2">
                ${this.contribution.author.name}
              </h5>
            </div>

            <aside>
              ${this.open
                ? html`
                    <button
                      @click=${this.handleClose}
                      class="btn btn-outline btn-error btn-sm"
                    >
                      Close
                    </button>

                    <button
                      @click=${this.handleMerge}
                      class="btn btn-primary btn-sm ml-2"
                    >
                      Merge
                    </button>
                  `
                : html`
                    <input
                      ${ref(this.inputRef)}
                      class="input input-bordered input-sm"
                      placeholder="Commit message"
                      ?disabled=${!this.isStale}
                    />
                    <button
                      @click=${this.handleSave}
                      class="btn btn-primary btn-sm"
                      ?disabled=${!this.isStale}
                    >
                      ${this.contribution.status === 'draft' ? 'Update' : 'Add'}
                    </button>
                    ${this.contribution.status === 'draft'
                      ? html`
                          <button
                            @click=${this.handleRemove}
                            class="btn btn-primary btn-sm"
                          >
                            Remove
                          </button>
                        `
                      : null}
                  `}
            </aside>
          </div>
        </div>
      </dialog>
    `
  }

  checkDirty = () => {
    window.onload = () => {
      window.addEventListener('beforeunload', (e) => {
        if (this.dirty) {
          const event = e || window.event
          event.returnValue =
            'It looks like you have been editing something. ' +
            'If you leave before saving, your changes will be lost.'
        } else {
          return undefined
        }
      })
    }
  }

  destroy() {
    if (!this.view) {
      return
    }

    this.view.destroy()
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('contribution-node-editor')) {
    customElements.define('contribution-node-editor', ContributionNodeEditor)
  }
})
