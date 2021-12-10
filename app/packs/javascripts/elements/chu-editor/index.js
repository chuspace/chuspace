// @flow

import { attr, controller, target } from '@github/catalyst'

import Editor from 'editor'
import { Transaction } from 'prosemirror-state'

@controller
export default class ChuEditor extends HTMLElement {
  @target revisionsModal: HTMLElement
  editor: Editor
  status: 'Saved'

  connectedCallback() {
    this.editor = new Editor({
      element: this,
      autoFocus: this.autofocus,
      editable: true,
      onChange: this.onChange,
      content: this.querySelector('textarea').value || '',
      revision: this.revision || '',
      appearance: 'default'
    })
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

  showRevisionsModal = (event) => {
    event.preventDefault()
    this.revisionsModal.classList.add('modal-open')
  }

  closeRevisionsModal = () => {
    event.preventDefault()
    this.revisionsModal.classList.remove('modal-open')
  }
}
