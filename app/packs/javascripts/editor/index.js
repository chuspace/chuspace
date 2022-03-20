// @flow

import './styles.sass'

import { Decoration, DecorationSet } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'
import { LitElement, html } from 'lit'
import { NodeSelection, Selection } from 'prosemirror-state'
import {
  PermanentUserData,
  Doc as YDoc,
  applyUpdateV2,
  decodeSnapshot,
  emptySnapshot,
  encodeSnapshot,
  encodeStateAsUpdateV2,
  equalSnapshots,
  snapshot
} from 'yjs'
import { baseKeymap, selectParentNode } from 'prosemirror-commands'
import { fromBase64, toBase64 } from 'lib0/buffer'
import { getMarkAttrs, isMarkActive, isNodeActive } from 'editor/helpers'
import { inputRules, undoInputRule } from 'prosemirror-inputrules'
import { markdownParser, markdownSerializer } from 'editor/markdowner'
import {
  prosemirrorToYDoc,
  redo,
  undo,
  yCursorPlugin,
  ySyncPlugin,
  ySyncPluginKey,
  yUndoPlugin
} from 'y-prosemirror'

import { ActionCableProvider } from 'editor/actioncable-provider'
import { CodeBlock as CodeBlockComponent } from 'editor/components'
import { EditorView } from 'prosemirror-view'
import { MarkdownParser } from 'prosemirror-markdown'
import { Schema } from 'prosemirror-model'
import SchemaManager from 'editor/schema'
import { createConsumer } from '@rails/actioncable'
import debounce from 'lodash.debounce'
import { dropCursor } from 'prosemirror-dropcursor'
import { gapCursor } from 'prosemirror-gapcursor'
import { keymap } from 'prosemirror-keymap'
import { post } from '@rails/request.js'
import { randomColor } from 'helpers/random-color'

const CUSTOM_ARROW_HANDLERS = ['code_block', 'front_matter']
const DEFAULT_EDITOR_NODES = ['doc', 'text', 'paragraph']

const awarenessStatesToArray = (states: Map<number, Record<string, any>>) => {
  return Array.from(states.entries()).map(([key, value]) => {
    return {
      clientId: key,
      ...value.user
    }
  })
}

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
    collaboration: { type: Object },
    excludeFrontmatter: { type: Boolean },
    imageProviderPath: { type: String },
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
    this.collaboration = null
    this.excludeFrontmatter = false
    this.mode = 'default'
    this.editable = true
    this.contribution = false

    if (this.mode === 'node') this.nodeName = 'paragraph'
  }

  async connectedCallback() {
    super.connectedCallback()

    if (this.collaboration) {
      this.ydoc = new YDoc()
      applyUpdateV2(this.ydoc, fromBase64(this.collaboration.ydoc))
    }

    this.manager = this.isNodeEditor
      ? new SchemaManager(this, [...DEFAULT_EDITOR_NODES, this.nodeName])
      : new SchemaManager(this)

    this.schema = this.manager.schema
    this.contentParser = markdownParser(this.schema)
    this.contentSerializer = markdownSerializer(this.schema)
    this.initialContent = this.querySelector('textarea.content').value

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
    let keymaps = {}

    if (this.collaboration) {
      this.users = []

      this.provider = new ActionCableProvider(
        createConsumer(),
        this.collaboration,
        this.ydoc
      )

      this.provider.on('synced', () => {
        this.permanentUserData = new PermanentUserData(this.ydoc)
        this.permanentUserData.setUserMapping(
          this.ydoc,
          this.ydoc.clientID,
          this.collaboration.user.username
        )
      })

      const render = (user) => {
        const cursor = document.createElement('span')

        cursor.classList.add('collaboration-cursor__caret')
        cursor.setAttribute('style', `border-color: ${user.color}`)

        const label = document.createElement('div')

        label.classList.add('collaboration-cursor__label')
        label.setAttribute('style', `background-color: ${user.color}`)
        label.insertBefore(document.createTextNode(user.name), null)
        cursor.insertBefore(label, null)

        return cursor
      }

      collaborationPlugins = [
        ySyncPlugin(this.ydoc.getXmlFragment('prosemirror'), {
          permanentUserData: this.permanentUserData
        }),
        yUndoPlugin(),
        yCursorPlugin(
          (() => {
            this.provider.awareness.setLocalStateField('user', {
              color: `#${randomColor(this.name)}`,
              ...this.collaboration.user
            })

            this.users = awarenessStatesToArray(this.provider.awareness.states)

            this.provider.awareness.on('update', () => {
              const update = awarenessStatesToArray(
                this.provider.awareness.states
              )

              this.users = awarenessStatesToArray(update)
            })

            return this.provider.awareness
          })(),
          {
            cursorBuilder: render
          }
        )
      ]

      const commands = {
        undo: () => ({ tr, state, dispatch }) => {
          tr.setMeta('preventDispatch', true)

          const undoManager: UndoManager = yUndoPluginKey.getState(state)
            .undoManager

          if (undoManager.undoStack.length === 0) {
            return false
          }

          if (!dispatch) {
            return true
          }

          return undo(state)
        },
        redo: () => ({ tr, state, dispatch }) => {
          tr.setMeta('preventDispatch', true)

          const undoManager: UndoManager = yUndoPluginKey.getState(state)
            .undoManager

          if (undoManager.redoStack.length === 0) {
            return false
          }

          if (!dispatch) {
            return true
          }

          return redo(state)
        }
      }

      keymaps = {
        'Mod-z': undo,
        'Mod-y': redo,
        'Mod-Shift-z': redo
      }
    }

    if (this.mode !== 'node') {
      keymaps = Object.assign({}, keymaps, {
        ArrowLeft: arrowHandler('left'),
        ArrowRight: arrowHandler('right'),
        ArrowUp: arrowHandler('up'),
        ArrowDown: arrowHandler('down'),
        'Ctrl-s': this.handleSave,
        'Mod-s': this.handleSave,
        Escape: selectParentNode
      })
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
        ...keymaps,
        Backspace: undoInputRule
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
    () => {
      const statusElement = document.getElementById('chu-editor-status')
      statusElement.textContent = 'Auto saving...'

      post(this.autoSavePath, {
        body: JSON.stringify({
          draft: {
            current_ydoc: toBase64(encodeStateAsUpdateV2(this.ydoc))
          }
        })
      })
    },
    2000,
    { maxWait: 5000 }
  )

  attachVersion = () => {
    const versions = this.ydoc.getArray('versions')
    const lastVersion =
      versions.length > 0
        ? decodeSnapshot(versions.get(versions.length - 1).snapshot)
        : emptySnapshot

    this.view.dispatch(
      this.view.state.tr.setMeta(ySyncPluginKey, {
        snapshot: null,
        prevSnapshot: lastVersion
      })
    )
  }

  addVersion = () => {
    const versions = this.ydoc.getArray('versions')
    const prevVersion =
      versions.length === 0 ? null : versions.get(versions.length - 1)
    const prevSnapshot =
      prevVersion === null
        ? emptySnapshot
        : decodeSnapshot(prevVersion.snapshot)

    const snapshot = snapshot(this.ydoc)

    if (prevVersion != null) {
      prevSnapshot.sv.set(
        prevVersion.clientID,
        prevSnapshot.sv.get(prevVersion.clientID) + 1
      )
    }

    if (!equalSnapshots(prevSnapshot, snapshot)) {
      versions.push([
        {
          date: new Date().getTime(),
          snapshot: encodeSnapshot(snapshot),
          clientID: this.ydoc.clientID
        }
      ])
    }
  }

  dispatchTransaction(transaction: Transaction) {
    this.state = this.state.apply(transaction)
    this.view.updateState(this.state)

    if (transaction.docChanged) {
      this.emitUpdate()
      this.autosave()
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
