// @flow

import { setBlockType, toggleBlockType } from 'editor/commands'

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'
import { Plugin } from 'prosemirror-state'
import { findParentNodeOfType } from 'prosemirror-utils'
import { textblockTypeInputRule } from 'prosemirror-inputrules'

export default class Title extends Node {
  name = 'title'

  get schema() {
    return {
      attrs: {
        class: {
          default: 'title',
          'data-text': 'title'
        }
      },
      content: 'text*',
      group: 'node',
      defining: true,
      draggable: false,

      parseDOM: [
        {
          tag: 'h1',
          attrs: {
            class: 'title',
            'data-text': 'title'
          }
        }
      ],
      toDOM: (node: PMNode) => [
        'h1',
        { class: 'title', 'data-text': 'title' },
        0
      ]
    }
  }

  commands({ type, schema }: PMNode) {
    return (attrs: {}) => toggleBlockType(type, schema.nodes.paragraph, attrs)
  }

  keys({ type }: PMNode) {
    return {
      [`Shift-Ctrl-t`]: setBlockType(type)
    }
  }

  inputRules({ type }: PMNode) {
    return [textblockTypeInputRule(new RegExp(`^(#{1,1})\\s$`), type, 1)]
  }

  get plugins() {
    return [
      new Plugin({
        props: {
          handleKeyDown: (view, event) => {
            const { schema, doc, tr, selection } = view.state
            const parent = findParentNodeOfType(schema.nodes.heading)(selection)

            if (!parent) return
            if (!parent.node) return

            if (
              event.code === 'Backspace' &&
              parent.node.textContent.length === 0
            ) {
              view.props.commands.title({})
              return true
            }

            return false
          }
        }
      })
    ]
  }
}
