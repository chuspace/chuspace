// @flow

import '@yaireo/tagify/dist/tagify.css'

import { controller, target } from '@github/catalyst'

import Tagify from '@yaireo/tagify'

@controller
export default class InputTags extends HTMLElement {
  @target element: HTMLFormElement

  connectedCallback() {
    const tagify = new Tagify(this.element)
  }
}
