// @flow

import { attr, controller, target } from '@github/catalyst'

import Editor from 'editor'
import { Transaction } from 'prosemirror-state'

@controller
export default class ChuEditor extends HTMLElement {
  @attr autofocus: boolean = true
  @attr imageProviderPath: string = ''
  @target content: HTMLElement
  @target form: HTMLElement
  @target diff: HTMLElement

  editor: Editor
  currentContent: string = ''
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

  setTextareaContent = (newContent) =>
    (this.content.querySelector('textarea').value = newContent)

  onChange = (transaction: Transaction) => {
    const newContent = this.editor.content
    this.diff.dataset.newContent = newContent
    this.setTextareaContent(newContent)
  }

  openCommitModal = (event) => {
    if (this.diff.dataset.newContent) {
      event.preventDefault()
      this.form.classList.add('modal-open')
      document.body.classList.add('overflow-hidden')
    }
  }

  closeCommitModal = () => {
    event.preventDefault()
    this.form.classList.remove('modal-open')
    document.body.classList.remove('overflow-hidden')
  }
}
