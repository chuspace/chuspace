// @flow

import { controller } from '@github/catalyst'

@controller
export default class TurboReconnect extends HTMLElement {
  connectedCallback() {
    this.autoCheckValidation()
  }

  autoCheckValidation = () => {
    const autoChecks = document.querySelectorAll('auto-check')

    autoChecks.forEach((check: HTMLElement) => {
      const input = check.querySelector('input')

      if (input) {
        input.addEventListener('auto-check-error', async function(event) {
          const { response, setValidity } = event.detail

          setValidity('Validation failed')
          const message = await response.text()
          input.classList.add('input-error')

          const hint = check.querySelector('.input-hint-message')
          if (hint) hint.classList.add('hidden')

          const error =
            check.querySelector('.input-error-message') ||
            document.createElement('div')

          error.classList.add(
            'text-xs',
            'mt-2',
            'text-error',
            'input-error-message'
          )

          error.textContent = message
          input.insertAdjacentElement('afterend', error)
        })

        input.addEventListener('auto-check-success', async function(event) {
          const { response } = event.detail
          const message = await response.text()
          input.classList.remove('input-error')
          const error = check.querySelector('.input-error-message')
          if (error) error.remove()
          const hint = check.querySelector('.input-hint-message')
          if (hint) hint.classList.remove('hidden')
        })
      }
    })
  }
}
