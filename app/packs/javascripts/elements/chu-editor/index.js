// @flow

import { attr, controller } from '@github/catalyst'

import Editor from 'editor'
import { Transaction } from 'prosemirror-state'

function getPreviousSibling(elem, callback) {
  // Get the next sibling element
  let sibling = elem.previousElementSibling

  // If there's no callback, return the first sibling
  if (!callback || typeof callback !== 'function') return sibling

  // If the sibling matches our test condition, use it
  // If not, jump to the next sibling and continue the loop
  let index = 0
  while (sibling) {
    if (callback(sibling, index, elem)) return sibling
    index++
    sibling = sibling.previousElementSibling
  }
}

function getNextSibling(elem, callback) {
  // Get the next sibling element
  let sibling = elem.nextElementSibling

  // If there's no callback, return the first sibling
  if (!callback || typeof callback !== 'function') return sibling

  // If the sibling matches our test condition, use it
  // If not, jump to the next sibling and continue the loop
  let index = 0
  while (sibling) {
    if (callback(sibling, index, elem)) return sibling
    index++
    sibling = sibling.nextElementSibling
  }
}

@controller
export default class ChuEditor extends HTMLElement {
  editor: Editor
  status: 'Saved'

  connectedCallback() {
    this.editor = new Editor({
      element: this,
      autoFocus: this.autofocus,
      editable: true,
      onChange: this.onChange,
      content: this.querySelector('#content').value || '',
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

  get payload() {
    return {
      body: this.editor.content
    }
  }

  createRenderRoot() {
    return this
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('chu-editor')) {
    customElements.define('chu-editor', ChuEditor)
  }
})
