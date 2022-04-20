// @flow

import { Decoration, DecorationSet } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'
import { Fragment, Schema } from 'prosemirror-model'
import { LitElement, html, render } from 'lit'
import { NodeSelection, Selection } from 'prosemirror-state'
import {
  PermanentUserData,
  Doc as YDoc,
  applyUpdateV2,
  decodeSnapshotV2,
  emptySnapshot,
  encodeSnapshotV2,
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
  yDocToProsemirror,
  ySyncPlugin,
  ySyncPluginKey,
  yUndoPlugin
} from 'y-prosemirror'

import { ActionCableProvider } from 'editor/actioncable-provider'
import { CodeBlock as CodeBlockComponent } from 'editor/components'
import { EditorView } from 'prosemirror-view'
import { MarkdownParser } from 'prosemirror-markdown'
import SchemaManager from 'editor/schema'
import { contributionWidgetKey } from 'editor/plugins/contribution/widget'
import { createConsumer } from '@rails/actioncable'
import debounce from 'lodash.debounce'
import { dropCursor } from 'prosemirror-dropcursor'
import { gapCursor } from 'prosemirror-gapcursor'
import { keymap } from 'prosemirror-keymap'
import { patch } from '@rails/request.js'
import { randomColor } from 'helpers/random-color'

const CUSTOM_ARROW_HANDLERS = ['code_block', 'front_matter']
const DEFAULT_EDITOR_NODES = ['doc', 'text', 'paragraph']

class LocalRemoteUserData extends PermanentUserData {
  /**
   * @param {number} clientid
   * @return {string}
   */
  getUserByClientId(clientid) {
    return super.getUserByClientId(clientid) || 'remote'
  }
  /**
   * @param {Y.ID} id
   * @return {string}
   */
  getUserByDeletedId(id) {
    return super.getUserByDeletedId(id) || 'remote'
  }
}

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

export type CollaborationUser = {
  name: string,
  id: number,
  username: string,
  avatar_url: string
}

export default class CollaborationEditor extends LitElement {
  static properties = {
    autoSavePath: { type: String },
    autoFocus: { type: Boolean },
    collaboration: { type: Object },
    excludeFrontmatter: { type: Boolean },
    imageUploadPath: { type: String },
    imageLoadPath: { type: String },
    editable: { type: Boolean },
    contribution: { type: Boolean },
    mode: { type: String },
    status: { type: String, reflect: true },
    onChange: { type: Function }
  }

  manager: SchemaManager
  schema: Schema
  collaboration: CollaborationUser = {}
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
    this.mode = 'default'
    this.editable = false
    this.contribution = false
  }

  async connectedCallback() {
    super.connectedCallback()

    if (this.collaboration.original_ydoc) {
      this.startingYDoc = new YDoc()
      this.startingYDoc.gc = false
      applyUpdateV2(
        this.startingYDoc,
        fromBase64(this.collaboration.original_ydoc)
      )
    }

    this.ydoc = new YDoc()
    this.ydoc.gc = false
    applyUpdateV2(this.ydoc, fromBase64(this.collaboration.ydoc))
    this.setupPermanentUserData()
    this.setupCollaboration()

    this.manager = new SchemaManager(this)
    this.schema = this.manager.schema
    this.contentParser = markdownParser(this.schema, false)
    this.contentSerializer = markdownSerializer(this.schema, false)

    this.state = this.createState()
    this.view = this.createView()

    this.setupCommands()
    this.setActiveNodesAndMarks()
    this.checkDirty()

    if (this.isDiffMode) {
      setTimeout(() => {
        this.attachVersion()
      }, 100)
    }
  }

  createRenderRoot() {
    return this
  }

  disconnectedCallback() {
    if (this.collaboration) this.provider?.destroy()
  }

  get isDiffMode() {
    return this.mode === 'diff'
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
        'Mod-z': undo,
        'Mod-y': redo,
        'Mod-Shift-z': redo,
        ArrowLeft: arrowHandler('left'),
        ArrowRight: arrowHandler('right'),
        ArrowUp: arrowHandler('up'),
        ArrowDown: arrowHandler('down'),
        'Ctrl-s': this.handleSave,
        'Mod-s': this.handleSave,
        Escape: selectParentNode,
        Backspace: undoInputRule
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
      }),
      ySyncPlugin(this.ydoc.getXmlFragment('prosemirror'), {
        permanentUserData: this.permanentUserData,
        colors: this.colors
      }),
      this.collaboration.channel &&
        yCursorPlugin(
          (() => {
            this.provider.awareness.setLocalStateField('user', {
              color: this.currentUserColor,
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
            renderCursor: this.renderCursor
          }
        ),
      yUndoPlugin()
    ].filter(Boolean)
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
      editable: () => this.editable,
      contribution: this.contribution,
      imageLoadPath: this.imageLoadPath,
      imageUploadPath: this.imageUploadPath,
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
      const statusElement = document.getElementById('chu-editor-status')
      if (statusElement) statusElement.textContent = 'Auto saving...'
      this.addVersion()

      const startingProsemirrorDoc = yDocToProsemirror(
        this.schema,
        this.startingYDoc
      )

      const startingFragment = Fragment.from(startingProsemirrorDoc)
      const currentFragment = Fragment.from(this.state.doc)
      const stale = startingFragment.findDiffStart(currentFragment)

      const response = await patch(this.autoSavePath, {
        body: JSON.stringify({
          draft: {
            current_ydoc: toBase64(encodeStateAsUpdateV2(this.ydoc)),
            doc_changed: !!stale
          }
        })
      })

      if (response.ok) {
        this.dirty = false
      }
    },
    2000,
    { maxWait: 5000 }
  )

  attachVersion = () => {
    const versions = this.ydoc.getArray('versions')

    this.dispatchTransaction(
      this.state.tr.setMeta(ySyncPluginKey, {
        snapshot: decodeSnapshotV2(versions.get(versions.length - 1).snapshot),
        prevSnapshot: decodeSnapshotV2(versions.get(0).snapshot)
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
        : decodeSnapshotV2(prevVersion.snapshot)

    const currentSnapshot = snapshot(this.ydoc)

    if (prevVersion != null) {
      // account for the action of adding a version to ydoc
      prevSnapshot.sv.set(
        prevVersion.clientID,
        /** @type {number} */ (prevSnapshot.sv.get(prevVersion.clientID)) + 1
      )
    }
    if (!equalSnapshots(prevSnapshot, currentSnapshot)) {
      versions.push([
        {
          date: new Date().getTime(),
          snapshot: encodeSnapshotV2(currentSnapshot),
          clientID: this.ydoc.clientID
        }
      ])
    }

    return currentSnapshot
  }

  dispatchTransaction(transaction: Transaction) {
    this.state = this.state.apply(transaction)
    this.view.updateState(this.state)

    if (this.contribution) this.renderContributionsToolbar()

    if (transaction.docChanged && this.editable) {
      this.dirty = true
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

  renderCursor = (user) => {
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

  renderContributionsToolbar = () => {
    const decorations = contributionWidgetKey.getState(this.state).decorations
      .local
    console.log(decorations)
    const div = this.querySelector('#contributions')

    if (decorations.length > 0) {
      div.className =
        'py-2 bg-base-200 z-10 fixed bottom-0 w-full left-0 right-0'
      const template = html`
        <div class="container flex justify-end">
          ${decorations.length} changes
          ${decorations.map((decoration) => {
            return html`
              <div>${decoration.type.spec.id}</div>
            `
          })}
          <button class="btn btn-primary">Commit</button>
        </div>
      `

      render(template, div)
    } else {
      div.className = null
      render(null, div)
    }
  }

  setupCommands = () => {
    this.view.props.commands = Object.assign({}, this.manager.commands, {
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
    })
  }

  setupPermanentUserData = () => {
    this.permanentUserData = new LocalRemoteUserData(
      this.ydoc,
      this.ydoc.getMap('users')
    )

    this.permanentUserData.setUserMapping(
      this.ydoc,
      this.ydoc.clientID,
      this.collaboration.user.username
    )

    return this.permanentUserData
  }

  setupCollaboration = () => {
    this.users = []

    this.currentUserColor = randomColor({
      luminosity: 'light',
      hue: 'orange',
      seed: this.collaboration.user.username
    })

    this.colors = Array.from(this.ydoc.getMap('users').keys()).map((key) => {
      return {
        light: randomColor({
          seed: key,
          hue: 'orange',
          luminosity: 'light'
        }),
        dark: randomColor({
          seed: key,
          hue: 'orange',
          luminosity: 'dark'
        })
      }
    })

    if (this.collaboration.channel) {
      this.provider = new ActionCableProvider(
        createConsumer(),
        this.collaboration,
        this.ydoc
      )

      this.provider.on('synced', () => this.setupPermanentUserData)
    }
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
  if (!window.customElements.get('collaboration-editor')) {
    customElements.define('collaboration-editor', CollaborationEditor)
  }
})
