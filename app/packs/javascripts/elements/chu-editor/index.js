// @flow

import { attr, controller, target } from '@github/catalyst'

import Editor from 'editor'
import { Transaction } from 'prosemirror-state'
import matter from 'gray-matter'

@controller
export default class ChuEditor extends HTMLElement {
  @attr autofocus: boolean = true
  @attr imageProviderPath: string = ''
  @target content: HTMLElement
  @target revisionsModal: HTMLElement
  editor: Editor
  status: 'Saved'

  connectedCallback() {
    this.editor = new Editor({
      element: this.content,
      autoFocus: this.autofocus,
      editable: true,
      onChange: this.onChange,
      imageProviderPath: this.imageProviderPath,
      content: this.content.querySelector('textarea').value || '',
      revision: this.revision || '',
      appearance: 'default'
    })

    this.editor.focus()
  }

  onChange = (transaction: Transaction) => {
    // if (this.saving) return

    // this.saving = true

    this.content.querySelector('textarea').value = this.editor.content

    // if (this.id) {
    //   this.autosave()
    // } else {
    //   this.create()
    // }
  }

  onSave = (event) => {
    event.preventDefault()
    this.revisionsModal.classList.add('modal-open')
  }

  closeRevisionsModal = () => {
    event.preventDefault()
    this.revisionsModal.classList.remove('modal-open')
  }
}
