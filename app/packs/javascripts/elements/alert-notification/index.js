// @flow

import { controller, target } from '@github/catalyst'

@controller
export default class AlertNotificationElement extends HTMLElement {
  @target element: HTMLElement

  connectedCallback() {
    setTimeout(this.hide, 5000)
  }

  hide = () =>
    this.element.classList.add(
      'transition-all',
      'duration-500',
      'ease-in-out',
      '-translate-y-full',
      'transform'
    )

  preventDefault = (event) => event.preventDefault()
}
