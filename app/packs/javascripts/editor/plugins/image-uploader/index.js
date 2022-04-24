// @flow

/* global FileReader */

import * as Rails from '@rails/ujs'

import { Decoration, DecorationSet } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey } from 'prosemirror-state'

import { Element } from 'editor/base'
import { customAlphabet } from 'nanoid'
import { imagePlaceholderKey } from '../image-placeholder'

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
                (plugin) => plugin.key === imagePlaceholderKey.key
              )

              let id = nanoid()
              let tr = view.state.tr
              if (!tr.selection.empty) tr.deleteSelection()

              tr.setMeta(placeholderPlugin, {
                add: { id, pos: tr.selection.anchor }
              })

              view.dispatch(tr)
              event.preventDefault()

              const { schema } = view.state

              images.forEach((image) => {
                const formData = new FormData()
                formData.append('image', image)
                let pos = placeholderPlugin.props.findPlaceholder(
                  view.state,
                  id
                )

                Rails.ajax({
                  type: 'POST',
                  url: view.props.imageUploadPath,
                  data: formData,
                  success: (data) => {
                    const node = schema.nodes.image.create({
                      src: data.url
                    })

                    if (pos == null) return

                    const transaction = view.state.tr
                      .insert(pos, node)
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
