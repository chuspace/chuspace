import { attr, controller, target } from '@github/catalyst'

@controller
export default class StorageFormElement extends HTMLElement {
  @target form: HTMLFormElement
  @target loader: HTMLDivElement
  @target scopes: HTMLPreElement
  @attr providers = {}

  connectedCallback() {
    this.obj = JSON.parse(this.providers)
  }

  changeScopes(event) {
    const provider = event.target.value

    this.scopes.innerHTML = this.obj[provider]['scopes']
  }
}
