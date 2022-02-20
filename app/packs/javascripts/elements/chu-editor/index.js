// @flow

import { attr, controller, target } from '@github/catalyst'

import Editor from 'editor'
import { Transaction } from 'prosemirror-state'
import debounce from 'lodash/debounce'
import { post } from '@rails/request.js'

@controller
export default class ChuEditor extends HTMLElement {
  @attr saving: boolean = false
  @attr readOnly: boolean = false
  @attr autofocus: boolean = true
  @attr imageProviderPath: string = ''
  @attr autoSavePath: string = ''
  @target content: HTMLElement
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
      appearance: 'default'
    })
  }

  autosave = debounce(
    async () => {
      this.saving = true
      const response = await post(this.autoSavePath, {
        body: JSON.stringify({ draft: { content: this.editor.content } })
      })

      if (response.ok) {
        this.saving = false
      }
    },
    1000,
    { maxWait: 1000 }
  )

  onChange = () => {
    this.status.textContent = 'Auto saving...'
    if (this.saving == 'true') return

    this.autosave()
  }
}
