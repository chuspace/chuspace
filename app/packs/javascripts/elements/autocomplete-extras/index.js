// @flow

import { attr, controller, target } from '@github/catalyst'
import { html, render } from 'lit-html'
@controller
export default class AutocompleteExtrasElement extends HTMLElement {
  @attr tags: boolean = false
  @attr items: string = []
  @target targetInput: HTMLInputElement
  @target valueInput: HTMLInputElement
  @target handle: HTMLButtonElement
  @target selections: HTMLDivElement
  @target completer: HTMLElement
  @target dropdown: HTMLElement

  connectedCallback() {
    if (this.tags) {
      this.tagsMap = new Map()

      this.items.split(',').forEach((item) => {
        this.tagsMap.set(item, item)
        this.renderTags()
      })

      this.completer.addEventListener('auto-complete-change', (event) => {
        if (this.completer.value.trim()) {
          this.tagsMap.set(this.completer.value.trim(), this.completer.value.trim())
          event.relatedTarget.value = ''
          this.renderTags()
          this.valueInput.value = Array.from(this.tagsMap.values()).join(',')
        }
      })
    }
  }

  clear = (event: MouseEvent) => {
    event.preventDefault()

    this.handle.classList.add('hidden')
    this.completer.value = ''
    this.dropdown.innerHTML = ''
    this.tagsMap.clear()
    this.targetInput.value = ''
  }

  removeTag = (key) => {
    this.tagsMap.delete(key)
    this.renderTags()
  }

  renderTags = () => {
    this.selections.innerHTML = ''

    this.tagsMap.forEach((value, key) => {
      const node = document.createElement('span')
      node.className = 'badge badge-primary gap-2 relative'

      if (this.selections.children.length > 0) node.classList.add('ml-2')

      render(
        html`
          <span>${value}</span>
          <button tabindex="-1" aria-label="Remove tag">
            <svg
              class="fill-current w-3 h-3"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
              @click=${(event) => this.removeTag(key)}
            >
              <path
                fill-rule="evenodd"
                d="M5.72 5.72a.75.75 0 011.06 0L12 10.94l5.22-5.22a.75.75 0 111.06 1.06L13.06 12l5.22 5.22a.75.75 0 11-1.06 1.06L12 13.06l-5.22 5.22a.75.75 0 01-1.06-1.06L10.94 12 5.72 6.78a.75.75 0 010-1.06z"
              ></path>
            </svg>
          </button>
        `,
        node
      )

      this.selections.append(node)
    })
  }
}
