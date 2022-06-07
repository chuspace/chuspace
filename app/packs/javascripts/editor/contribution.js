// @flow

import { EditorState, Transaction } from 'prosemirror-state'
import { LitElement, html, render } from 'lit'
import { markdownParser, markdownSerializer } from 'editor/markdowner'
import { post, put } from '@rails/request.js'

import { CodeBlock as CodeBlockComponent } from 'editor/components'
import { EditorView } from 'prosemirror-view'
import { MarkdownParser } from 'prosemirror-markdown'
import { Schema } from 'prosemirror-model'
import SchemaManager from 'editor/schema'
import { contributionWidgetKey } from 'editor/plugins/contribution/widget'
import { keymap } from 'prosemirror-keymap'

export type User = {
  name: string,
  id: number,
  username: string,
  avatar_url: string
}

export type Contribution = {
  content: string,
  type: string,
  node: PMNode,
  author: User,
  posFrom: number,
  posTo: number
}

export default class ContributionEditor extends LitElement {
  static properties = {
    imageLoadPath: { type: String },
    editable: { type: Boolean },
    contribution: { type: Boolean },
    contributions: { type: Array },
    contributionsPath: { type: String },
    user: { type: Object }
  }

  manager: SchemaManager
  schema: Schema
  contentParser: MarkdownParser
  contentSerializer: contentSerializer
  contribution: boolean = false
  contributions: ?[Contribution] = []
  user: User = {}
  state: EditorState
  view: EditorView

  constructor() {
    super()

    this.autoFocus = false
    this.editable = false
    this.contribution = true
    this.contributions = []
    this.uncommittedContributions = new Map()
  }

  connectedCallback() {
    super.connectedCallback()

    this.manager = new SchemaManager(this)
    this.schema = this.manager.schema
    this.contentParser = markdownParser(this.schema, false)
    this.contentSerializer = markdownSerializer(this.schema, false)
    this.initialContent = this.querySelector('textarea.content').value
    this.doc = this.contentParser.parse(this.initialContent)

    this.state = this.createState()
    this.view = this.createView()
    this.checkDirty()
  }

  disconnectedCallback() {
    super.disconnectedCallback()

    this.destroy()
  }

  createRenderRoot() {
    return this
  }

  get plugins() {
    return this.manager.contributionPlugins
  }

  createState = () =>
    EditorState.create({
      doc: this.doc,
      editor: this,
      schema: this.schema,
      contributions: this.contributions,
      plugins: this.plugins
    })

  createView() {
    const view = new EditorView(this, {
      state: this.state,
      schema: this.schema,
      editable: () => this.editable,
      contribution: this.contribution,
      imageLoadPath: this.imageLoadPath,
      dispatchTransaction: this.dispatchTransaction.bind(this),
      nodeViews: this.manager.nodeViews
    })

    view.dom.style.whiteSpace = 'pre-wrap'
    view.dom.title = 'Enter post content'
    view.dom.id = 'editor-content'
    view.dom.classList.add('chu-editor', 'read-only')

    return view
  }

  handleSave = (e: Event) => {
    this.emitUpdate()
    return true
  }

  addContribution = (contribution) => {
    const transaction = this.state.tr.setMeta(contributionWidgetKey, {
      ...contribution,
      status: 'draft',
      add: true
    })

    this.uncommittedContributions.set(contribution.id, contribution)
    this.view.dispatch(transaction)
    this.dirty = true
  }

  removeContribution = (contribution) => {
    const transaction = this.state.tr.setMeta(contributionWidgetKey, {
      ...contribution,
      add: false
    })
    this.view.dispatch(transaction)
    this.uncommittedContributions.delete(contribution.id)
    this.renderContributionsToolbar()
  }

  closeContribution = async (contribution) => {
    this.updateContribution(contribution, 'closed')
  }

  mergeContribution = async (contribution) => {
    // Do more to merge
    this.updateContribution(contribution, 'merged')
  }

  updateContribution = async (contribution, status) => {
    const response = await put(contribution.path, {
      body: JSON.stringify({ status }),
      contentType: 'application/json',
      responseKind: 'json'
    })

    if (response.ok) {
      const data = await response.json

      if (data.revision) {
        const revision = JSON.parse(data.revision)
        const transaction = this.state.tr.setMeta(contributionWidgetKey, {
          ...revision,
          add: true
        })

        this.view.dispatch(transaction)
      }
    }
  }

  openContributions = async () => {
    const body = Array.from(this.uncommittedContributions).map(
      ([id, contribution]) => {
        return {
          pos_from: contribution.posFrom,
          pos_to: contribution.posTo,
          content_before: contribution.contentBefore,
          content_after: contribution.contentAfter,
          node: contribution.node,
          widget_pos: contribution.widgetPos
        }
      }
    )

    const response = await post(this.contributionsPath, {
      body: JSON.stringify({ revisions: body }),
      contentType: 'application/json',
      responseKind: 'json'
    })

    if (response.ok) {
      this.dirty = false

      const data = await response.json
      this.contributions = this.contributions.concat(JSON.parse(data.revisions))
      this.uncommittedContributions.clear()
      this.renderContributionsToolbar()

      const transaction = this.state.tr.setMeta(contributionWidgetKey, {
        contributions: this.contributions,
        reload: true
      })

      this.view.dispatch(transaction)
    }
  }

  renderContributionsToolbar = () => {
    const div = this.querySelector('#contributions')

    if (this.uncommittedContributions.size > 0) {
      div.className =
        'py-2 bg-base-200 z-10 fixed bottom-0 w-full left-0 right-0'
      const template = html`
        <div class="container flex items-center justify-end">
          ${this.uncommittedContributions.size} changes
          <button class="btn btn-primary" @click=${this.openContributions}>
            Commit
          </button>
        </div>
      `

      render(template, div)
    } else {
      div.className = null
      render(null, div)
    }
  }

  dispatchTransaction(transaction: Transaction) {
    this.state = this.state.apply(transaction)
    this.view.updateState(this.state)
    this.renderContributionsToolbar()
    return true
  }

  destroy() {
    if (!this.view) {
      return
    }

    this.view.destroy()
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
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('contribution-editor')) {
    customElements.define('contribution-editor', ContributionEditor)
  }
})
