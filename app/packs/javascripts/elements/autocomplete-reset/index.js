// @flow

import { controller, target } from '@github/catalyst'

@controller
export default class AutocompleteReset extends HTMLElement {
  @target input: HTMLDialogElement
  @target handle: HTMLButtonElement

  clear = (event: MouseEvent) => {
    event.preventDefault()

    this.handle.classList.add('hidden')
    this.querySelector('auto-complete').value = ''
    this.querySelector('ul').innerHTML = ''
    this.input.value = ''
  }

  toggle = (event: Event) => {
    const value = event.target.value

    if (value) this.handle.classList.remove('hidden')
    else this.clear(event)
  }

  select = (event: Event) => {
    console.log(event)
    this.input.value = event.target.dataset.autocompleteValue
    this.querySelector('ul').innerHTML = ''
  }
}
