// @flow

import { attr, controller, target } from '@github/catalyst'

import Headroom from 'headroom.js'
import throttle from 'lodash.throttle'

@controller
export default class FlexibleHeaderElement extends HTMLElement {
  @attr enabled: boolean = false
  @target element: HTMLFormElement

  connectedCallback() {
    // const headroom = new Headroom(this.element)
    // headroom.init()

    console.log(this.enabled)
    if (this.enabled) {
      document.addEventListener('mousemove', this.hideIdleHeader)
      this.hideIdleHeader()
    }
  }

  hideIdleHeader = throttle(() => {
    if (this.idleTimeout) {
      clearTimeout(this.idleTimeout)
      this.idleTimeout = null
      return
    }

    this.element.classList.remove('header--hide')
    this.element.classList.add('header--show')

    this.idleTimeout = setTimeout(() => {
      this.element.classList.remove('header--show')
      this.element.classList.add('header--hide')
    }, 1000)
  }, 10)
}
