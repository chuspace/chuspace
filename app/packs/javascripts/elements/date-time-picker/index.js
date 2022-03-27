// @flow

import { controller, target } from '@github/catalyst'

import flatpickr from 'flatpickr'

import('flatpickr/dist/themes/dark.css')

@controller
export default class DateTimePickerElement extends HTMLElement {
  @target element: HTMLFormElement

  connectedCallback() {
    const picker = flatpickr(this.element, {
      enableTime: true,
      dateFormat: 'Y-m-d H:i'
    })
  }
}
