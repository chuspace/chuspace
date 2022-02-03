// @flow

import { attr, controller, target } from '@github/catalyst'

import ActioncableClient from 'helpers/actioncable-client'
import Editor from 'editor'
import { Transaction } from 'prosemirror-state'
import debounce from 'lodash/debounce'

@controller
export default class ChuEditor extends HTMLElement {
  @attr draftPath: string
  @attr saving: boolean = false
  @attr readOnly: boolean = false
  @attr publicationPermalink: integer
  @attr autofocus: boolean = true
  @attr imageProviderPath: string = ''
  @target content: HTMLElement
  @target revision: HTMLElement
  @target form: HTMLElement
  @target status: HTMLElement

  editor: Editor
  channel: string = 'AutosaveChannel'

  connectedCallback() {
    const readOnly = JSON.parse(this.readOnly)

    this.editor = new Editor({
      element: this.content,
      autoFocus: this.autofocus,
      editable: !readOnly,
      onChange: this.onChange,
      imageProviderPath: this.imageProviderPath,
      content: this.content.querySelector('textarea')?.value || '',
      revision: this.revision?.querySelector('textarea')?.value || '',
      appearance: 'default'
    })

    if (!this.readOnly) {
      this.subscription = ActioncableClient.subscribe(
        {
          channel: this.channel,
          publication_permalink: this.publicationPermalink,
          path: this.draftPath
        },
        {
          received: this.onRecieved
        }
      )
      this.editor.focus()
    }
  }

  disconnectedCallback() {
    if (ActioncableClient.subscribedTo(this.channel)) {
      ActioncableClient.unsubscribe(this.channel)
    }
  }

  attributeChangedCallback(
    name: string,
    oldValue: string | null,
    newValue: string | null
  ) {
    if (name == 'data-saving') this.updateStatuses()
  }

  onRecieved = (data: any) => (this.saving = false)

  updateStatuses() {
    this.status.textContent = this.saving
      ? 'Auto saving...'
      : 'Everything up to date.'
  }

  autosave = debounce(
    () => {
      this.saving = true
      this.subscription.send({
        body: this.editor.content
      })
    },
    1000,
    { maxWait: 1000 }
  )

  onChange = (transaction: Transaction) => {
    if (this.saving == 'true') return

    this.autosave()
  }
}
