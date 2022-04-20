// @flow

import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'
import { Fragment, Schema } from 'prosemirror-model'
import { LitElement, html } from 'lit'
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

import { CodeBlock as CodeBlockComponent } from 'editor/components'
import { EditorView } from 'prosemirror-view'
import { History } from 'editor/plugins'
import { MarkdownParser } from 'prosemirror-markdown'
import SchemaManager from 'editor/schema'
import { dropCursor } from 'prosemirror-dropcursor'
import { gapCursor } from 'prosemirror-gapcursor'
import { inputRules } from 'prosemirror-inputrules'
import { keymap } from 'prosemirror-keymap'
import { patch } from '@rails/request.js'
import { randomColor } from 'helpers/random-color'

const DEFAULT_EDITOR_NODES = ['doc', 'text', 'paragraph']

export default class NodeEditor extends LitElement {
  static properties = {
    author: { type: Object },
    autoFocus: { type: Boolean },
    diff: { type: Boolean },
    editable: { type: Boolean },
    nodeName: { type: String },
    onChange: { type: Function },
    onEditorInit: { type: Function },
    yDocBase64: { type: String }
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

    this.excludeFrontmatter = true
    this.nodeName = 'paragraph'
    this.mode = 'node'
    this.commits = []
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

    if (this.yDocBase64) {
      this.ydoc = new Doc()
      applyUpdateV2(this.ydoc, fromBase64(this.yDocBase64))
    } else {
      this.initialContent = this.querySelector('textarea.content').value
      this.doc = this.contentParser.parse(this.initialContent)
      this.ydoc = prosemirrorToYDoc(this.doc)
    }

    this.ydoc.gc = false
    this.setupYDocUser()
    this.setupYDocUserColor()
    this.setupYDocVersions()

    this.state = this.createState()
    this.view = this.createView()

    if (this.autoFocus) this.focus()
    // this.checkDirty()

    this.onEditorInit(this)
  }

  createRenderRoot() {
    return this
  }

  disconnectedCallback() {
    super.disconnectedCallback()
    if (this.collaboration) this.provider?.destroy()
  }

  attributeChangedCallback(name, oldVal, newVal) {
    super.attributeChangedCallback(name, oldVal, newVal)

    if (this.state) {
      if (name === 'diff' && this.diff) {
        this.attachVersion()
      } else {
        this.detachVersion()
      }
    }
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
      }),
      ySyncPlugin(this.ydoc.getXmlFragment('prosemirror'), {
        permanentUserData: this.permanentUserData,
        colors: this.colors
      }),
      yUndoPlugin()
    ]
  }

  createState = () =>
    EditorState.create({
      schema: this.schema,
      commits: this.commits,
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

  attachVersion = () => {
    const versions = this.ydoc.getArray('versions')

    this.dispatchTransaction(
      this.state.tr.setMeta(ySyncPluginKey, {
        snapshot: decodeSnapshotV2(versions.get(versions.length - 1).snapshot),
        prevSnapshot: decodeSnapshotV2(versions.get(0).snapshot)
      })
    )
  }

  detachVersion = () => {
    const binding = ySyncPluginKey.getState(this.state).binding
    if (binding != null) {
      binding.unrenderSnapshot()
    }
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

  setupYDocUser = (): void => {
    this.permanentUserData = new PermanentUserData(this.ydoc)
    this.permanentUserData.setUserMapping(
      this.ydoc,
      this.ydoc.clientID,
      this.author.username
    )
  }

  setupYDocUserColor = (): void => {
    this.currentUserColor = randomColor({
      luminosity: 'light',
      hue: 'orange',
      seed: this.author.username
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
  }

  setupYDocVersions = (): void => {
    this.versions = this.ydoc.getArray('versions')
    this.versions.push([
      {
        date: new Date().getTime(),
        snapshot: encodeSnapshotV2(snapshot(this.ydoc)),
        clientID: this.ydoc.clientID
      }
    ])
  }

  dispatchTransaction(transaction: Transaction) {
    this.state = this.state.apply(transaction)
    this.view.updateState(this.state)

    if (transaction.docChanged && this.editable) {
      this.addVersion()
      this.emitUpdate()
    }

    return true
  }

  emitUpdate() {
    this.editable ? this.onChange && this.onChange() : false
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

  get toYDocBase64() {
    return toBase64(encodeStateAsUpdateV2(this.ydoc))
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
