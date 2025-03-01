// @flow

import { LitElement, html, svg } from 'lit'

import { customAlphabet } from 'nanoid'

const nanoid = customAlphabet('1234567890abcdef', 10)

export default class ContentLoader extends LitElement {
  static get properties() {
    return {
      type: { type: String },
      lines: { type: Number },
      width: { type: Number },
      height: { type: Number },
    }
  }

  constructor() {
    super()
    this.type = 'default'

    this.width = 730
    this.height = 300

    this.lines = 1
  }

  createRenderRoot() {
    return this
  }

  render() {
    const props = {
      animate: true,
      ariaLabel: 'Loading interface...',
      baseUrl: '',
      gradientRatio: 2,
      boxHeight: 400,
      interval: 0.25,
      preserveAspectRatio: 'none',
      primaryColor: '#1A243B',
      primaryOpacity: 1,
      rtl: false,
      secondaryColor: '#313a4f',
      secondaryOpacity: 1,
      speed: 2,
      style: {},
      boxWidth: 400,
      className: 'loader',
    }

    const idClip = nanoid()
    const idGradient = nanoid()
    const rtlStyle = props.rtl ? { transform: 'scaleX(-1)' } : {}
    const keyTimes = `0; ${props.interval}; 1`
    const dur = `${props.speed}s`
    const clipPath = `url(${props.baseUrl}#${idClip})`

    if (this.type !== 'image') {
      this.height = this.lines * 20
    }

    this.boxHeight = this.height

    return svg`
      <svg
        role="img"
        aria-labelledby=${props.ariaLabel ? props.ariaLabel : null}
        viewBox=${`0 0 ${this.width} ${this.boxHeight}`}
        preserveAspectRatio=${props.preserveAspectRatio}
      >
        ${
          props.ariaLabel
            ? svg`
                <title>${props.ariaLabel}</title>
              `
            : null
        }
        <rect
          x="0"
          y="0"
          width=${this.width}
          height=${this.boxHeight}
          clip-path=${`url(${props.baseUrl}#${idClip})`}
          style=${`fill:url(${props.baseUrl}#${idGradient})`}
        />

        <defs>
          <clipPath id=${idClip}>
          <rect x="0" y="0" width=${this.width} height=${this.height} />
          </clipPath>

          <linearGradient id=${idGradient}>
            <stop offset="0%" stop-color=${props.primaryColor} stop-opacity=${props.primaryOpacity}>
              <animate
                attributeName="offset"
                values=${`${-props.gradientRatio}; ${-props.gradientRatio}; 1`}
                keyTimes=${keyTimes}
                dur=${dur}
                repeatCount="indefinite"
              />
            </stop>

            <stop offset="50%" stop-color="${props.secondaryColor}" stop-opacity="${props.secondaryOpacity}">
              <animate
                attributeName="offset"
                values=${`${-props.gradientRatio / 2}; ${-props.gradientRatio / 2}; ${1 + props.gradientRatio / 2}`}
                keyTimes=${keyTimes}
                dur=${dur}
                repeatCount="indefinite"
              />
            </stop>

            <stop offset="100%" stop-color=${props.primaryColor} stop-opacity=${props.primaryOpacity}>
              <animate
                attributeName="offset"
                values=${`0; 0; ${1 + props.gradientRatio}`}
                keyTimes=${keyTimes}
                dur=${dur}
                repeatCount="indefinite"
              />
            </stop>
          </linearGradient>
        </defs>
      </svg>
    `
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('content-loader')) {
    customElements.define('content-loader', ContentLoader)
  }
})
