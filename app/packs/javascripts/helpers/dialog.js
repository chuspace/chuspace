/* global Document */

// @flow

class DocumentWithBody extends Document {
  // $FlowFixMe
  body: HTMLBodyElement
}

declare var document: DocumentWithBody

export default class Dialog {
  dialog: typeof window.HTMLDialogElement

  constructor(dialogElement: HTMLElement) {
    this.dialog = dialogElement

    if (typeof HTMLDialogElement !== 'function') {
      dialogPolyfill.registerDialog(this.dialog)
    }
  }

  hide() {
    if (!this.dialog.open) return
    this.dialog.close()
    document.body.classList.remove('dialog-open')
    document.body.scroll = 'yes'
  }

  show() {
    if (this.dialog.open) return

    document.body.scroll = 'no'
    document.body.classList.add('dialog-open')
    this.dialog.showModal()
  }
}
