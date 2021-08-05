import { controller, target } from '@github/catalyst'

@controller
export default class AutoRefreshFormElement extends HTMLElement {
  @target form: HTMLFormElement
  @target loader: HTMLElement

  connectedCallback() {
    const completer = document.querySelector('auto-complete')
    const input = completer.querySelector('input')
    const content = document.getElementById(completer.getAttribute('for'))

    const spinner = document.createElement('div')
    spinner.className = 'spinner hidden absolute top-0 z-10 right-0 mr-4 mt-2'
    input.insertAdjacentElement('afterend', spinner)

    input.addEventListener('input', (event) => {
      const target = event.target as HTMLTextAreaElement

      if (target.value) spinner.classList.remove('hidden')

      if ((target as HTMLTextAreaElement) && !target.value) {
        content.setAttribute('hidden', 'true')
      }
    })

    completer.addEventListener('load', () => {
      spinner.classList.add('hidden')
    })

    completer.addEventListener('loadend', () => spinner.classList.add('hidden'))
    completer.addEventListener('error', () => spinner.classList.add('hidden'))
  }

  refresh(event) {
    this.loader.innerHTML = `<div class="spinner"></div>`
    this.form.requestSubmit()
  }

  reset(event) {
    if (!event.target.value) this.form.requestSubmit()
  }
}
