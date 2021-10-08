// @flow

import './styles.sass'

import { Change, ChangeSet, Span, simplifyChanges } from 'prosemirror-changeset'
import { DOMSerializer, Schema } from 'prosemirror-model'
import { Decoration, DecorationSet } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'
import { baseKeymap, selectParentNode } from 'prosemirror-commands'
import { getMarkAttrs, isMarkActive, isNodeActive } from 'editor/helpers'
import { inputRules, undoInputRule } from 'prosemirror-inputrules'
import { markdownParser, markdownSerializer } from 'editor/markdowner'

import { EditorView } from 'prosemirror-view'
import { MarkdownParser } from 'prosemirror-markdown'
import SchemaManager from 'editor/schema'
import { Selection } from 'prosemirror-state'
import { dropCursor } from 'prosemirror-dropcursor'
import { gapCursor } from 'prosemirror-gapcursor'
import { keymap } from 'prosemirror-keymap'

function arrowHandler(dir) {
  return (state, dispatch, view) => {
    if (state.selection.empty && view.endOfTextblock(dir)) {
      let side = dir == 'left' || dir == 'up' ? -1 : 1,
        $head = state.selection.$head
      let nextPos = Selection.near(
        state.doc.resolve(side > 0 ? $head.after() : $head.before()),
        side
      )

      if (nextPos.$head && nextPos.$head.parent.type.name == 'code_block') {
        dispatch(state.tr.setSelection(nextPos))
        return true
      }
    }
    return false
  }
}

export type Options = {
  autoFocus: boolean,
  element: HTMLElement,
  imageProviderPath: string,
  content: string,
  revision: string,
  editable: boolean,
  appearance: 'default' | 'comment' | 'plain' | 'contribution',
  onChange: (transaction: Transaction) => void
}

export default class Editor {
  options: Options = {}
  element: HTMLElement
  manager: SchemaManager
  schema: Schema
  markdownParser: MarkdownParser
  markdownSerializer: markdownSerializer
  state: EditorState
  view: EditorView
  activeMarks: {}
  activeNodes: {}
  activeMarkAttrs: {}

  constructor(options: Options) {
    this.options = options
    this.element = options.element
    this.manager = new SchemaManager(this)

    this.schema = this.manager.schema
    this.markdownParser = markdownParser(this.schema)
    this.markdownSerializer = markdownSerializer

    this.state = this.createState()
    this.view = this.createView()
    this.view.props.commands = this.manager.commands
    this.setActiveNodesAndMarks()

    if (this.options.autoFocus) this.focus()
  }

  get plugins() {
    return [
      ...this.manager.plugins,
      inputRules({
        rules: this.manager.inputRules
      }),
      ...this.manager.pasteRules,
      ...this.manager.keymaps,
      keymap(baseKeymap),
      keymap({
        Backspace: undoInputRule,
        ArrowLeft: arrowHandler('left'),
        ArrowRight: arrowHandler('right'),
        ArrowUp: arrowHandler('up'),
        ArrowDown: arrowHandler('down'),
        'Ctrl-s': this.handleSave,
        'Mod-s': this.handleSave,
        Escape: selectParentNode
      }),

      dropCursor(),
      gapCursor(),
      new Plugin({
        key: new PluginKey('editable'),
        props: {
          editable: () => !!this.options.editable
        }
      }),
      new Plugin({
        props: {
          attributes: {
            tabindex: 0
          }
        }
      })
    ]
  }

  createState = () => {
    let doc = this.markdownParser.parse(this.options.content)
    let plugins = this.plugins

    return EditorState.create({
      schema: this.schema,
      doc: doc,
      highlights: [],
      editions: [],
      plugins
    })
  }

  createView() {
    const view = new EditorView(this.element, {
      state: this.state,
      editable: () => !!this.options.editable,
      imageProviderPath: this.options.imageProviderPath,
      dispatchTransaction: this.dispatchTransaction.bind(this),
      nodeViews: this.manager.nodeViews
    })

    view.dom.style.whiteSpace = 'pre-wrap'
    view.dom.title = 'Markdown editor'
    view.dom.classList.add(
      'chu-editor',
      this.options.editable ? 'editable' : 'read-only'
    )

    return view
  }

  handleSave = (e: Event) => {
    this.options.editable ? this.options.onChange() : false
    return true
  }

  dispatchTransaction(transaction: Transaction) {
    this.state = this.state.apply(transaction)
    this.view.updateState(this.state)

    if (!transaction.docChanged) {
      return
    }

    this.emitUpdate(transaction)
  }

  emitUpdate(transaction: Transaction) {
    this.options.editable ? this.options.onChange(transaction) : false
  }

  focus() {
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
      (types, [name, value]: [string, Function]) => ({
        ...types,
        [name]: (attrs = {}) => value(attrs)
      }),
      {}
    )
  }

  get content() {
    const markdown = this.markdownSerializer.serialize(this.state.doc)
    return markdown
  }

  destroy() {
    if (!this.view) {
      return
    }

    this.view.destroy()
  }
}
