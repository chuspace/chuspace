// @flow

import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'
import { LitElement, html } from 'lit'
import { NodeSelection, Selection } from 'prosemirror-state'
import { baseKeymap, selectParentNode } from 'prosemirror-commands'
import { markdownParser, markdownSerializer } from 'editor/markdowner'

import { CodeBlock as CodeBlockComponent } from 'editor/components'
import { EditorView } from 'prosemirror-view'
import { History } from 'editor/plugins'
import { MarkdownParser } from 'prosemirror-markdown'
import { Schema } from 'prosemirror-model'
import SchemaManager from 'editor/schema'
import { dropCursor } from 'prosemirror-dropcursor'
import { gapCursor } from 'prosemirror-gapcursor'
import { inputRules } from 'prosemirror-inputrules'
import { keymap } from 'prosemirror-keymap'
import { patch } from '@rails/request.js'

const DEFAULT_EDITOR_NODES = ['doc', 'text', 'paragraph']

export default class NodeEditor extends LitElement {
  static properties = {
    autoFocus: { type: Boolean },
    editable: { type: Boolean },
    nodeName: { type: String },
    onChange: { type: Function }
  }

  manager: SchemaManager
  schema: Schema
  contentParser: MarkdownParser
  contentSerializer: contentSerializer
  state: EditorState
  view: EditorView
  activeMarks: {}
  activeNodes: {}
  activeMarkAttrs: {}
  dirty: boolean = false

  constructor() {
    super()

    this.autoFocus = false
    this.editable = false
    this.excludeFrontmatter = true
    this.nodeName = 'paragraph'
    this.mode = 'node'
  }

  async connectedCallback() {
    super.connectedCallback()

    this.manager = new SchemaManager(this, [
      ...DEFAULT_EDITOR_NODES,
      this.nodeName
    ])

    this.schema = this.manager.schema
    this.contentParser = markdownParser(this.schema, true)
    this.contentSerializer = markdownSerializer(this.schema, true)

    this.initialContent = this.querySelector('textarea.content').value
    this.doc = this.contentParser.parse(this.initialContent)

    this.state = this.createState()
    this.view = this.createView()

    if (this.autoFocus) this.focus()
    // this.checkDirty()
  }

  createRenderRoot() {
    return this
  }

  disconnectedCallback() {
    if (this.collaboration) this.provider?.destroy()
  }

  get plugins() {
    return [
      inputRules({
        rules: this.manager.inputRules
      }),
      ...this.manager.pasteRules,
      ...this.manager.keymaps,
      keymap(baseKeymap),

      dropCursor(),
      gapCursor(),

      ...new History(this).plugins,
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
      contributions: [],
      plugins: this.plugins
    })

  createView() {
    const view = new EditorView(this, {
      state: this.state,
      schema: this.schema,
      editable: () => this.editable,
      imageLoadPath: this.imageLoadPath,
      imageUploadPath: this.imageUploadPath,
      contributionPath: this.contributionPath,
      dispatchTransaction: this.dispatchTransaction.bind(this),
      nodeViews: this.manager.nodeViews
    })

    view.dom.style.whiteSpace = 'pre-wrap'
    view.dom.title = 'Enter post content'
    view.dom.id = 'editor-content'
    view.dom.classList.add(
      'chu-editor',
      this.editable ? 'editable' : 'read-only'
    )

    return view
  }

  handleSave = (e: Event) => {
    this.emitUpdate()
    return true
  }

  dispatchTransaction(transaction: Transaction) {
    this.state = this.state.apply(transaction)
    this.view.updateState(this.state)

    if (transaction.docChanged && this.editable) {
      this.emitUpdate()
    }

    return true
  }

  emitUpdate() {
    this.editable ? this.onChange && this.onChange(this.content) : false
  }

  focus() {
    const tr = this.state.tr.setSelection(Selection.atEnd(this.state.doc))
    this.view.dispatch(tr)
    this.view.focus()
  }

  blur() {
    this.view.dom.blur()
  }

  get content() {
    return this.contentSerializer.serialize(this.state.doc)
  }

  checkDirty() {
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
  if (!window.customElements.get('node-editor')) {
    customElements.define('node-editor', NodeEditor)
  }
})
