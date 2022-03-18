// @flow

/* global FileReader */

import * as Rails from '@rails/ujs'

import { Decoration, DecorationSet } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey } from 'prosemirror-state'

import { Element } from 'editor/base'
import { customAlphabet } from 'nanoid'

const nanoid = customAlphabet('1234567890abcdef', 10)
const IMAGE_INPUT_REGEX = /!\[(.+|:?)\]\((\S+)(?:(?:\s+)["'](\S+)["'])?\)/

export default class ImageUploader extends Element {
  name = 'image-uploader'

  get plugins() {
    return [
      new Plugin({
        key: new PluginKey('image-uploader'),
        props: {
          handleDOMEvents: {
            drop(view, event) {
              const hasFiles =
                event.dataTransfer &&
                event.dataTransfer.files &&
                event.dataTransfer.files.length

              if (!hasFiles) {
                return
              }

              const images = Array.from(
                event.dataTransfer.files
              ).filter((file) => /image/i.test(file.type))

              if (images.length === 0) {
                return
              }

              const placeholderPlugin = view.state.plugins.find(
                (plugin) => plugin.key === 'image-placeholder$1'
              )
              const findPlaceholder = placeholderPlugin.props.findPlaceholder
              let id = nanoid()
              let tr = view.state.tr
              if (!tr.selection.empty) tr.deleteSelection()

              tr.setMeta(placeholderPlugin, {
                add: { id, pos: tr.selection.from }
              })
              view.dispatch(tr)

              event.preventDefault()

              const { schema } = view.state
              const coordinates = view.posAtCoords({
                left: event.clientX,
                top: event.clientY
              })

              images.forEach((image) => {
                const formData = new FormData()
                formData.append('image', image)
                let pos = findPlaceholder(view.state, id)

                Rails.ajax({
                  type: 'POST',
                  url: view.props.imageProviderPath,
                  data: formData,
                  success: (data) => {
                    const node = schema.nodes.image.create({
                      src: data.url
                    })

                    if (pos == null) return

                    const transaction = view.state.tr
                      .replaceWith(pos, pos, node)
                      .setMeta(placeholderPlugin, { remove: { id } })
                    view.dispatch(transaction)
                  },
                  error: (data) => {
                    view.dispatch(
                      tr.setMeta(placeholderPlugin, { remove: { id } })
                    )
                  }
                })
              })
            }
          }
        }
      })
    ]
  }
}
