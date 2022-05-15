// @flow

import { Decoration, DecorationSet } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'
import { Fragment, Schema } from 'prosemirror-model'
import { LitElement, html } from 'lit'
import { NodeSelection, Selection } from 'prosemirror-state'
import { baseKeymap, selectParentNode } from 'prosemirror-commands'
import { getMarkAttrs, isMarkActive, isNodeActive } from 'editor/helpers'
import { inputRules, undoInputRule } from 'prosemirror-inputrules'
import { markdownParser, markdownSerializer } from 'editor/markdowner'

import { CodeBlock as CodeBlockComponent } from 'editor/components'
import { EditorView } from 'prosemirror-view'
import { MarkdownParser } from 'prosemirror-markdown'
import SchemaManager from 'editor/schema'
import debounce from 'lodash.debounce'
import { dropCursor } from 'prosemirror-dropcursor'
import { gapCursor } from 'prosemirror-gapcursor'
import { keymap } from 'prosemirror-keymap'
import { patch } from '@rails/request.js'

const CUSTOM_ARROW_HANDLERS = ['code_block', 'front_matter']

function arrowHandler(dir) {
  return (state, dispatch, view) => {
    if (state.selection.empty && view.endOfTextblock(dir)) {
      let side = dir == 'left' || dir == 'up' ? -1 : 1,
        $head = state.selection.$head
      let nextPos = Selection.near(state.doc.resolve(side > 0 ? $head.after() : $head.before()), side)

      if (CUSTOM_ARROW_HANDLERS.includes(nextPos?.$head?.parent?.type?.name)) {
        if (nextPos.$head.parent.type.name === 'front_matter') {
          nextPos = state.doc.resolve(0, nextPos.$head.parent.nodeSize)

          dispatch(state.tr.setSelection(new NodeSelection(nextPos)))
        } else {
          dispatch(state.tr.setSelection(nextPos))
        }
        return true
      }
    }

    return false
  }
}

export default class ChuEditor extends LitElement {
  static properties = {
    autoSavePath: { type: String },
    autoFocus: { type: Boolean },
    excludeFrontmatter: { type: Boolean },
    imageUploadPath: { type: String },
    imageLoadPath: { type: String },
    editable: { type: Boolean },
    mode: { type: String },
    status: { type: String, reflect: true },
    onChange: { type: Function },
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

    this.excludeFrontmatter = false
    this.mode = 'default'
    this.editable = false
  }

  connectedCallback() {
    super.connectedCallback()
    this.manager = new SchemaManager(this)

    this.schema = this.manager.schema
    this.contentParser = markdownParser(this.schema, this.isNodeEditor)
    this.contentSerializer = markdownSerializer(this.schema, this.isNodeEditor)

    this.initialContent = this.querySelector('textarea.content').value
    this.doc = this.contentParser.parse(this.initialContent)

    this.state = this.createState()
    this.view = this.createView()

    this.view.props.commands = this.manager.commands

    this.checkDirty()
  }

  createRenderRoot() {
    return this
  }

  disconnectedCallback() {
    super.disconnectedCallback()
    this.destroy()
  }

  get isNodeEditor() {
    return this.mode === 'node' && !!this.nodeName
  }

  get isDiffMode() {
    return this.mode === 'diff'
  }

  get plugins() {
    return [
      ...this.manager.plugins,
      inputRules({
        rules: this.manager.inputRules,
      }),
      ...this.manager.pasteRules,
      ...this.manager.keymaps,
      keymap(baseKeymap),
      keymap({
        ArrowLeft: arrowHandler('left'),
        ArrowRight: arrowHandler('right'),
        ArrowUp: arrowHandler('up'),
        ArrowDown: arrowHandler('down'),
        'Ctrl-s': this.handleSave,
        'Mod-s': this.handleSave,
        Escape: selectParentNode,
        Backspace: undoInputRule,
      }),

      dropCursor(),
      gapCursor(),

      new Plugin({
        key: new PluginKey('editable'),
        props: {
          editable: () => this.editable,
        },
      }),
      new Plugin({
        key: new PluginKey('tabindex'),
        props: {
          attributes: {
            tabindex: 0,
          },
        },
      }),
    ]
  }

  createState = () => {
    let options = {
      doc: this.doc,
      schema: this.schema,
      plugins: this.plugins,
    }

    return EditorState.create(options)
  }

  createView() {
    const view = new EditorView(this, {
      state: this.state,
      schema: this.schema,
      attributes: {
        spellcheck: 'false',
      },
      editable: () => this.editable,
      imageLoadPath: this.imageLoadPath,
      imageUploadPath: this.imageUploadPath,
      dispatchTransaction: this.dispatchTransaction.bind(this),
      nodeViews: this.manager.nodeViews,
    })

    view.dom.style.whiteSpace = 'pre-wrap'
    view.dom.title = 'Enter post content'
    view.dom.id = 'editor-content'
    view.dom.classList.add('chu-editor', this.editable ? 'editable' : 'read-only')

    return view
  }

  handleSave = (e: Event) => {
    this.emitUpdate()
    return true
  }

  autosave = debounce(
    async () => {
      const statusElement = document.getElementById('chu-editor-status')
      if (statusElement) statusElement.textContent = 'Auto saving...'

      const response = await patch(this.autoSavePath, {
        body: JSON.stringify({
          draft: {
            content: this.content,
          },
        }),
      })

      if (response.ok) {
        this.dirty = false
      }
    },
    2000,
    { maxWait: 5000 }
  )

  dispatchTransaction(transaction: Transaction) {
    this.state = this.state.apply(transaction)
    this.view.updateState(this.state)

    if (transaction.docChanged && this.editable) {
      this.dirty = true
      this.emitUpdate()
      this.autosave()
    }

    return true
  }

  emitUpdate() {
    console.log(this.content)
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
            'It looks like you have been editing something. ' + 'If you leave before saving, your changes will be lost.'
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
  if (!window.customElements.get('chu-editor')) {
    customElements.define('chu-editor', ChuEditor)
  }
})
