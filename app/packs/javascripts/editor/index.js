// @flow

import './styles.sass'

import { LitElement, html } from 'lit'
import { Schema } from 'prosemirror-model'
import { Decoration, DecorationSet } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'
import { NodeSelection, Selection } from 'prosemirror-state'
import { baseKeymap, selectParentNode } from 'prosemirror-commands'
import { getMarkAttrs, isMarkActive, isNodeActive } from 'editor/helpers'
import { inputRules, undoInputRule } from 'prosemirror-inputrules'
import { markdownParser, markdownSerializer } from 'editor/markdowner'

import { EditorView } from 'prosemirror-view'
import { MarkdownParser } from 'prosemirror-markdown'
import SchemaManager from 'editor/schema'
import { dropCursor } from 'prosemirror-dropcursor'
import { gapCursor } from 'prosemirror-gapcursor'
import { keymap } from 'prosemirror-keymap'
import debounce from 'lodash/debounce'
import { post } from '@rails/request.js'

import * as Y from 'yjs'

import {
  ySyncPlugin,
  yCursorPlugin,
  yUndoPlugin,
  undo,
  redo,
  prosemirrorToYDoc
} from 'y-prosemirror'

import { WebsocketProvider } from './websocket-provider'

const CUSTOM_ARROW_HANDLERS = ['code_block', 'front_matter']
const DEFAULT_EDITOR_NODES = ['doc', 'text', 'paragraph']

function arrowHandler(dir) {
  return (state, dispatch, view) => {
    if (state.selection.empty && view.endOfTextblock(dir)) {
      let side = dir == 'left' || dir == 'up' ? -1 : 1,
        $head = state.selection.$head
      let nextPos = Selection.near(
        state.doc.resolve(side > 0 ? $head.after() : $head.before()),
        side
      )

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
    collab: { type: Boolean },
    imageProviderPath: { type: String },
    username: { type: String },
    editable: { type: Boolean },
    contribution: { type: Boolean },
    contributionPath: { type: String },
    nodeName: { type: String },
    mode: { type: String },
    status: { type: String, reflect: true },
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

  constructor() {
    super()

    if (this.contribution && !this.contributionPath) {
      throw 'Contribution path must be set'
    }

    this.autoFocus = false
    this.collab = false
    this.mode = 'default'
    this.editable = true
    this.contribution = false

    if (this.mode === 'node') this.nodeName = 'paragraph'
  }

  connectedCallback() {
    super.connectedCallback()

    this.manager = this.isNodeEditor
      ? new SchemaManager(this, [...DEFAULT_EDITOR_NODES, this.nodeName])
      : new SchemaManager(this)

    this.schema = this.manager.schema
    this.contentParser = markdownParser(this.schema)
    this.contentSerializer = markdownSerializer(this.schema)

    this.initialContent = this.querySelector('textarea.content').value
    this.doc = this.contentParser.parse(this.initialContent)

    this.state = this.createState()
    this.view = this.createView()

    this.view.props.commands = this.manager.commands
    this.setActiveNodesAndMarks()
  }

  createRenderRoot() {
    return this
  }

  get isNodeEditor() {
    return this.mode === 'node' && !!this.nodeName
  }

  get plugins() {
    let collaborationPlugins = []

    if (this.collab) {
      const ydoc = new prosemirrorToYDoc(this.doc)

      const provider = new WebsocketProvider('CollabChannel', ydoc, {
        params: { username: this.username }
      })

      collaborationPlugins = [
        ySyncPlugin(ydoc.getXmlFragment('prosemirror')),
        yCursorPlugin(provider.awareness),
        yUndoPlugin()
      ]
    }

    let fullModePlugins = []

    if (this.mode !== 'node') {
      fullModePlugins = {
        ArrowLeft: arrowHandler('left'),
        ArrowRight: arrowHandler('right'),
        ArrowUp: arrowHandler('up'),
        ArrowDown: arrowHandler('down'),
        'Ctrl-s': this.handleSave,
        'Mod-s': this.handleSave,
        Escape: selectParentNode
      }
    }

    return [
      ...this.manager.plugins,
      inputRules({
        rules: this.manager.inputRules
      }),
      ...this.manager.pasteRules,
      ...this.manager.keymaps,
      keymap(baseKeymap),
      keymap({
        ...fullModePlugins,
        Backspace: undoInputRule,
        'Mod-z': undo,
        'Mod-y': redo,
        'Mod-Shift-z': redo
      }),

      dropCursor(),
      gapCursor(),

      new Plugin({
        key: new PluginKey('editable'),
        props: {
          editable: () => !!this.editable
        }
      }),
      new Plugin({
        key: new PluginKey('tabindex'),
        props: {
          attributes: {
            tabindex: 0
          }
        }
      }),
      ...collaborationPlugins
    ]
  }

  createState = () =>
    EditorState.create({
      schema: this.schema,
      doc: this.doc,
      contributions: [],
      plugins: this.plugins
    })

  createView() {
    const view = new EditorView(this, {
      state: this.state,
      schema: this.schema,
      editable: () => !!this.editable,
      imageProviderPath: this.imageProviderPath,
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

  autosave = debounce(
    async () => {
      this.status.textContent = 'Auto saving...'

      const response = await post(this.autoSavePath, {
        body: JSON.stringify({
          draft: { content: this.content }
        })
      })
    },
    2000,
    { maxWait: 5000 }
  )

  dispatchTransaction(transaction: Transaction) {
    this.state = this.state.apply(transaction)
    this.view.updateState(this.state)

    if (transaction.docChanged) this.emitUpdate()

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

  setActiveNodesAndMarks() {
    this.activeMarks = Object.entries(this.schema.marks).reduce(
      (marks, [name, mark]) => ({
        ...marks,
        [name]: (attrs = {}) => isMarkActive(this.state, mark, attrs)
      }),
      {}
    )

    this.activeMarkAttrs = Object.entries(this.schema.marks).reduce(
      (marks, [name, mark]) => ({
        ...marks,
        [name]: getMarkAttrs(this.state, mark)
      }),
      {}
    )

    this.activeNodes = Object.entries(this.schema.nodes).reduce(
      (nodes, [name, node]) => ({
        ...nodes,
        [name]: (attrs = {}) => isNodeActive(this.state, node, attrs)
      }),
      {}
    )
  }

  getMarkAttrs(type: string) {
    return this.activeMarkAttrs[type]
  }

  get isActive() {
    return Object.entries({
      ...this.activeMarks,
      ...this.activeNodes
    }).reduce(
      (types, [name, value]: [{ type: String }, Function]) => ({
        ...types,
        [name]: (attrs = {}) => value(attrs)
      }),
      {}
    )
  }

  get content() {
    return this.contentSerializer.serialize(this.state.doc)
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
