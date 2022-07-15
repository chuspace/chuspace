// @flow

import { controller, target } from '@github/catalyst'

@controller
export default class DialogOpenerElement extends HTMLElement {
  @target dialog: HTMLDialogElement

  connectedCallback() {
    if (this.dialog.classList.contains('modal-open')) {
      document.body.classList.add('dialog-open')
    }

    document.onkeydown = (event) => {
      if (
        event.key == 'Escape' &&
        this.dialog.classList.contains('modal-open')
      ) {
        this.close(event)
      }
    }
  }

  open = (e: MouseEvent) => {
    e.preventDefault()

    this.dialog.classList.add('modal-open')
  }

  close = (e: MouseEvent) => {
    e.preventDefault()
    this.dialog.classList.remove('modal-open')
    document.body.classList.remove('dialog-open')
  }
}
