// @flow

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'
import { toggleWrap } from 'editor/commands'
import { wrappingInputRule } from 'prosemirror-inputrules'

export default class Blockquote extends Node {
  name = 'blockquote'

  get schema() {
    return {
      content: 'block*',
      group: 'block',
      defining: true,
      draggable: false,
      parseDOM: [{ tag: 'blockquote' }],
      toDOM: () => ['blockquote', 0]
    }
  }

  commands({ type, schema }: PMNode) {
    return () => toggleWrap(type)
  }

  keys({ type }: PMNode) {
    return {
      'Ctrl->': toggleWrap(type)
    }
  }

  inputRules({ type }: PMNode) {
    return [wrappingInputRule(/^\s*>\s$/, type)]
  }
}
