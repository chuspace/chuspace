// @flow

import * as Rails from '@rails/ujs'

import { Node as ProsemirrorNode, Schema } from 'prosemirror-model'
import { html, render } from 'lit'

import BaseView from './base'
import type { BaseViewPropType } from './base'
import { EditorView } from 'prosemirror-view'
import isUrl from 'is-url'
import queryString from 'query-string'

export default class ImageView extends BaseView {
  constructor(props: BaseViewPropType & { imageLoadPath: string }) {
    super(props, false)

    this.imageLoadPath = props.imageLoadPath
    this.containerNode = document.createElement('div')
    this.renderElement()
  }

  renderElement = () => {
    const fileName = this.node.attrs.src.split('/').pop()
    const src = isUrl(this.node.attrs.src)
      ? this.node.attrs.src
      : `${this.imageLoadPath}?${queryString.stringify({
          path: this.node.attrs.src,
        })}`

    render(
      html`
        <lazy-image
          src=${src}
          alt=${this.node.attrs.alt || fileName}
          title=${this.node.attrs.title || this.node.attrs.alt || fileName}
          filename=${fileName}
          ?editable=${this.editable}
          .handleChange=${this.editable ? this.handleChange : null}
          .handleDelete=${this.handleDelete}
        ></lazy-image>
      `,
      this.containerNode
    )

    this.dom = this.containerNode.children[0]
    this.containerNode = this.dom
  }

  handleChange = (attrs: ?{ align: String, alt: string } = {}) => {
    this.node.attrs = Object.assign({}, this.node.attrs, attrs)
    this.outerView.dispatch(this.outerView.state.tr.setNodeMarkup(this.getPos(), null, this.node.attrs))
  }

  handleDelete = () => {
    this.destroy()
  }

  stopEvent = () => true
}
