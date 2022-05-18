// @flow

import { controller, target } from '@github/catalyst'

@controller
export default class DetailsMenuFormElement extends HTMLElement {
  @target form: HTMLFormElement
  @target input: HTMLInputElement
  @target loader: HTMLElement

  onChange = (event) => {
    this.input.value = event.detail.relatedTarget?.textContent?.trim()
  }

  submit = (event) => {
    this.onChange(event)

    if (this.loader) {
      this.loader.innerHTML = `<div class="text-center mt-4"><span class='btn btn-lg btn-ghost btn-circle loading'></span></div>`
    }

    this.form.requestSubmit()
  }
}
