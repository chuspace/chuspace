// @flow

import 'tippy.js/dist/tippy.css'
import 'tippy.js/themes/translucent.css'
import 'tippy.js/animations/scale.css'

import { LitElement, html, render } from 'lit'
import tippy, { followCursor, inlinePositioning, sticky } from 'tippy.js'

import truncate from 'lodash/truncate'

export default class LinkPreview extends LitElement {
  static get properties() {
    return {
      href: { type: String }
    }
  }

  tooltipMarkup = (url: string, data: any) => {
    const node = document.createElement('div')

    const template = html`
      <a
        href=${url}
        class="block link link--default"
        rel="noopener noreferrer"
        target="_blank"
      >
        <div class="flex items-center py-2">
          ${data.thumbnail_url
            ? html`
                <div class="popover-media mr-4">
                  <img
                    alt=${data.title}
                    title=${data.title}
                    data-src="${data.thumbnail_url}"
                    width="200"
                    height="200"
                    data-sizes="auto"
                    class="lazy"
                  />
                </div>
              `
            : null}
          <div class="popover-content text-left">
            <h1 class="text-base mb-2 font-bold">
              ${data.title}
            </h1>
            <p>${truncate(data.description, { length: 70 })}</p>
            <small class="block mt-2 font-bold">${data.provider_name}</small>
          </div>
        </div>
      </a>
    `

    render(template, node)

    return node.innerHTML
  }

  connectedCallback() {
    super.connectedCallback()

    const INITIAL_CONTENT = `<div class='flex' style="margin:5px 0;">
      <content-loader type="image" class='w-1/3 mr-2' width='200' height='200'></content-loader>
      <content-loader lines="3" class='w-2/3 mt-4' width="200" height='200'></content-loader>
    </div>`

    tippy(this, {
      content: INITIAL_CONTENT,
      animation: 'scale',
      theme: 'light',
      allowHTML: true,
      inlinePositioning: true,
      delay: 300,
      maxWidth: 350,
      interactive: true,
      sticky: true,
      followCursor: 'initial',
      plugins: [followCursor, sticky, inlinePositioning],
      touch: 'hold',
      popperOptions: {
        positionFixed: true
      },
      appendTo: document.body,
      arrow: true,
      onCreate: (instance) => {
        // Setup our own custom state properties
        instance.isFetching = false
      },
      onShow: async (instance) => {
        if (
          instance.state.isFetching === true ||
          instance.state.canFetch === false
        ) {
          return
        }

        instance.state.isFetching = true
        instance.state.canFetch = false
        instance.popper.style.width = '350px'

        try {
          const response = await fetch(
            `https://embed.chuspace.com/oembed?url=${this.href}&omit_script=1&iframe=card&omit_css=1`,
            {
              headers: {
                'Content-Type': 'application/json'
              },
              redirect: 'follow',
              referrerPolicy: 'no-referrer'
            }
          )

          const data = await response.json()
          if (!data.title) throw new Error(data)

          if (!instance.state.isVisible) {
            return
          }

          instance.setContent(this.tooltipMarkup(this.href, data))
        } catch (error) {
          console.log(error)
          instance.setContent(
            '<div class="text-center">Link preview unavailable</div>'
          )
        } finally {
          instance.state.isFetching = false
        }
      },

      onHidden(instance) {
        instance.state.canFetch = true
      }
    })
  }
  createRenderRoot() {
    return this
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('link-preview')) {
    customElements.define('link-preview', LinkPreview)
  }
})
