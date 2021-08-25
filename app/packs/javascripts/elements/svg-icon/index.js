// @flow

import { LitElement, svg } from 'lit'

import icons from './icons.json'

export default class SvgIcon extends LitElement {
  static get properties() {
    return {
      name: { type: String },
      width: { type: Number },
      height: { type: Number },
      fontsize: { type: String },
      color: { type: String },
      stroke: { type: String },
      feather: { type: String },
      className: { type: String }
    }
  }

  renderCustom = () =>
    new DOMParser()
      .parseFromString(
        `<svg
          xmlns="http://www.w3.org/2000/svg"
          width="${this.width}" height="${this.height}"
          viewBox="0 0 24 24"
          fill="${this.color}"
        >
          ${icons[this.name]}
        </svg>`,
        'image/svg+xml'
      )
      .querySelector('svg')

  renderFeather = () =>
    new DOMParser()
      .parseFromString(
        `<svg
          xmlns="http://www.w3.org/2000/svg"
          width="${this.width}"
          height="${this.height}"
          viewBox="0 0 24 24"
          fill="${this.color}"
          stroke="${this.stroke}"
          stroke-width="2"
          stroke-linecap="round"
          stroke-linejoin="round"
          class="${this.className}"
        >
          ${icons[this.name]}
        </svg>`,
        'image/svg+xml'
      )
      .querySelector('svg')

  constructor() {
    super()

    this.width = 20
    this.height = 20
    this.color = 'none'
    this.stroke = 'currentColor'
    this.className = 'block'

    try {
      this.feather = JSON.parse(this.feather)
    } catch (e) {}
  }

  createRenderRoot() {
    return this
  }

  render() {
    return svg`
      ${this.feather ? this.renderFeather() : this.renderCustom()}
    `
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('svg-icon')) {
    customElements.define('svg-icon', SvgIcon)
  }
})
