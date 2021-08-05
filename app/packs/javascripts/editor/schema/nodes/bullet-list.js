// @flow

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'
import { toggleList } from 'editor/commands'
import { wrappingInputRule } from 'prosemirror-inputrules'

export default class BulletList extends Node {
  name = 'bullet_list'

  get schema() {
    return {
      content: 'list_item+',
      group: 'block',
      parseDOM: [{ tag: 'ul' }],
      toDOM: () => ['ul', 0]
    }
  }

  commands({ type, schema }: PMNode) {
    return () => toggleList(type, schema.nodes.list_item)
  }

  keys({ type, schema }: PMNode) {
    return {
      'Shift-Ctrl-8': toggleList(type, schema.nodes.list_item)
    }
  }

  inputRules({ type }: PMNode) {
    return [wrappingInputRule(/^\s*([-+*])\s$/, type)]
  }
}
