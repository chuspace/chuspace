import { controller } from '@github/catalyst'

@controller
export default class ModalBoxElement extends HTMLElement {
  close(event) {
    event.preventDefault()
    this.classList.remove('modal-open')
  }

  open(event) {
    event.preventDefault()

    this.classList.add('modal-open')
  }
}
