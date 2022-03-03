// @flow

import { attr, controller, target } from '@github/catalyst'

import Editor from 'editor'
import { Transaction } from 'prosemirror-state'
import debounce from 'lodash/debounce'
import { post } from '@rails/request.js'

@controller
export default class ChuEditor extends HTMLElement {
  @attr editable: string = 'true'
  @attr autofocus: string = 'true'
  @attr imageProviderPath: string = ''
  @attr autoSavePath: string = ''
  @attr username: string = ''
  @target content: HTMLElement
  @target status: HTMLElement

  editor: Editor
  channel: string = 'AutosaveChannel'

  connectedCallback() {
    this.editor = new Editor({
      element: this.content,
      autoFocus: JSON.parse(this.autofocus),
      editable: JSON.parse(this.editable),
      onChange: this.onChange,
      imageProviderPath: this.imageProviderPath,
      content: this.content.querySelector('textarea')?.value || '',
      username: this.username,
      appearance: 'default'
    })
  }

  autosave = debounce(
    async () => {
      this.status.textContent = 'Auto saving...'

      const response = await post(this.autoSavePath, {
        body: JSON.stringify({ draft: { content: this.editor.content } })
      })
    },
    2000,
    { maxWait: 5000 }
  )

  onChange = () => {
    //this.autosave()
  }
}
