// @flow

import { controller, target, targets } from '@github/catalyst'

@controller
export default class AutoRefreshFormElement extends HTMLElement {
  @target form: HTMLFormElement
  @target loader: HTMLElement
  @target autoCompleter: HTMLElement
  @target autoCompleteInput: HTMLInputElement

  connectedCallback() {
    const completer = document.querySelector('auto-complete')

    if (completer) {
      const input = completer.querySelector('input')
      const content = document.getElementById(completer.getAttribute('for'))

      const spinner = document.createElement('div')
      spinner.className =
        'btn btn-sm btn-circle loading hidden absolute bottom-0 z-10 right-0 mr-4 mb-2'
      input.insertAdjacentElement('afterend', spinner)

      input.addEventListener('input', (event) => {
        const target = event.target

        if (target.value) spinner.classList.remove('hidden')

        if (target && !target.value) {
          content.setAttribute('hidden', 'true')
        }
      })

      completer.addEventListener('load', () => {
        spinner.classList.add('hidden')
      })

      completer.addEventListener('loadend', () =>
        spinner.classList.add('hidden')
      )
      completer.addEventListener('error', () => spinner.classList.add('hidden'))
    }
  }

  refresh = (event) => {
    if (this.loader) {
      this.loader.innerHTML = `<div class="text-center mt-4"><span class='btn btn-lg btn-ghost btn-circle loading'></span></div>`
    }

    this.form.requestSubmit()
  }

  onAutoCompleteItemClick(event) {
    this.autoCompleteInput.value = event.target.dataset.id
    this.refresh()
  }

  reset(event) {
    this.autoCompleteInput.value = null
  }
}
