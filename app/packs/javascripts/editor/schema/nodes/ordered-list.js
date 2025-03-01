// @flow

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'
import { toggleList } from 'editor/commands'
import { wrappingInputRule } from 'prosemirror-inputrules'

export default class OrderedList extends Node {
  name = 'ordered_list'

  get schema() {
    return {
      attrs: {
        order: {
          default: 1
        }
      },
      content: 'list_item+',
      group: 'block',
      parseDOM: [
        {
          tag: 'ol',
          getAttrs: (dom: PMNode) => ({
            order: dom.hasAttribute('start') ? +dom.getAttribute('start') : 1
          })
        }
      ],
      toDOM: (node: PMNode) => (node.attrs.order === 1 ? ['ol', 0] : ['ol', { start: node.attrs.order }, 0])
    }
  }

  commands({ type, schema }: PMNode) {
    return () => toggleList(type, schema.nodes.list_item)
  }

  keys({ type, schema }: PMNode) {
    return {
      'Shift-Ctrl-9': toggleList(type, schema.nodes.list_item)
    }
  }

  inputRules({ type }: PMNode) {
    return [
      wrappingInputRule(
        /^(\d+)\.\s$/,
        type,
        match => ({ order: +match[1] }),
        (match, node) => node.childCount + node.attrs.order === +match[1]
      )
    ]
  }
}
