// @flow

import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'

import { Node } from 'editor/base'
import { nodeInputRule } from 'editor/commands'

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
}
