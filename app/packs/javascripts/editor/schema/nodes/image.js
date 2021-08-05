// @flow

/* global FileReader */

import * as Rails from '@rails/ujs'

import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'
import { customAlphabet } from 'nanoid'
import { nodeInputRule } from 'editor/commands'

const nanoid = customAlphabet('1234567890abcdef', 10)
const IMAGE_INPUT_REGEX = /!\[(.+|:?)\]\((\S+)(?:(?:\s+)["'](\S+)["'])?\)/

export default class Image extends Node {
  name = 'image'

  get schema() {
    return {
      attrs: {
        src: {},
        alt: {
          default: null
        },
        title: {
          default: null
        }
      },
      inline: true,
      group: 'inline',
      draggable: false,
      parseDOM: [
        {
          tag: 'img[src]',
          getAttrs: (dom: PMNode) => ({
            src: dom.getAttribute('src'),
            title: dom.getAttribute('title'),
            alt: dom.getAttribute('alt')
          })
        }
      ],
      toDOM: (node: PMNode) => ['img', node.attrs]
    }
  }

  inputRules({ type }: PMNode) {
    return [
      nodeInputRule(IMAGE_INPUT_REGEX, type, (match) => {
        const [, alt, src, title] = match

        return {
          src,
          alt,
          title
        }
      })
    ]
  }

  commands({ type }: PMNode) {
    return (attrs: {}) => (state: EditorState, dispatch: Transaction) => {
      const { selection } = state
      const position = selection.$cursor
        ? selection.$cursor.pos
        : selection.$to.pos
      const node = type.create(attrs)
      const transaction = state.tr.insert(position, node)
      dispatch(transaction)
    }
  }

  get plugins() {
    return [
      new Plugin({
        key: new PluginKey('image'),
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
