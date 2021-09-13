// @flow

import * as Rails from '@rails/ujs'

import { LitElement, html } from 'lit'

import ActioncableClient from '../../helpers/actioncable-client'
import Editor from '../../editor'
import { Transaction } from 'prosemirror-state'
import debounce from 'lodash/debounce'
import readingTime from '../../helpers/reading-time'

export default class ChuEditor extends LitElement {
  editor: Editor
  status: 'Saved'

  static get properties() {
    return {
      url: { type: String, reflect: true },
      id: { type: String },
      param: { type: String },
      publicationId: { type: String },
      content: { type: String },
      revision: { type: String },
      channel: { type: String },
      appearance: { type: String },
      editable: { type: Boolean },
      imageProviderPath: { type: String },
      saving: { type: Boolean, reflect: true },
      autofocus: { type: Boolean }
    }
  }

  constructor() {
    super()

    this.param = 'post'
    this.appearance = 'default'
  }

  onRecieved = (data: any) => {
    this.saving = false
  }

  async connectedCallback() {
    await super.connectedCallback()

    this.editor = new Editor({
      element: this,
      autoFocus: this.autofocus,
      editable: true,
      imageProviderPath: this.imageProviderPath,
      placeholder: 'Write your post',
      onChange: this.onChange,
      content: this.content || '',
      revision: this.revision || '',
      appearance: this.appearance
    })
  }

  disconnectedCallback() {
    super.disconnectedCallback()

    if (ActioncableClient.subscribedTo('PostChannel'))
      ActioncableClient.unsubscribe('PostChannel')

    this.editor.destroy()

    window.onbeforeunload = null
  }

  updateStatuses() {
    const status = document.getElementById('editor-status')
    if (status) status.textContent = this.saving ? 'Saving...' : 'Saved'
  }

  updated = () => {
    if (this.editable && this.id) {
      window.onbeforeunload = () =>
        this.saving ? 'Are you sure you want to navigate away?' : null

      this.updateStatuses()

      this.subscription = ActioncableClient.subscribe(
        {
          channel: this.channel,
          publication_id: this.publicationId,
          id: this.id
        },
        {
          received: this.onRecieved
        }
      )
    }
  }

  onChange = (transaction: Transaction) => {
    // if (this.saving) return

    // this.saving = true
    console.log(this.payload)
    this.querySelector('textarea').value = this.editor.content

    // if (this.id) {
    //   this.autosave()
    // } else {
    //   this.create()
    // }
  }

  get payload() {
    return {
      body: this.editor.content
    }
  }

  autosave = debounce(
    () => {
      this.subscription.send(this.payload)
    },
    500,
    { maxWait: 500 }
  )

  create = debounce(
    () => {
      fetch(this.url, {
        method: 'POST',
        body: JSON.stringify({ [this.param]: this.payload }),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-TOKEN': Rails.csrfToken()
        }
      })
        .then((response) => response.json())
        .then(async (response) => {
          if (response.redirect) {
            window.history.pushState(null, 'Edit', response.redirect)
            this.id = response.id
            await this.requestUpdate()

            const header = document.getElementById('post_header')
            if (header) header.innerHTML = response.header
          }

          return response
        })
        .finally(() => (this.saving = false))
    },
    2000,
    { maxWait: 2000 }
  )

  createRenderRoot() {
    return this
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('chu-editor')) {
    customElements.define('chu-editor', ChuEditor)
  }
})
