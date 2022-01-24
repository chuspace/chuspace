// @flow

import { controller, target } from '@github/catalyst'

@controller
export default class InputTags extends HTMLElement {
  @target element: HTMLFormElement

  connectedCallback() {
    const tagify = new Tagify(this.element)
  }
}
