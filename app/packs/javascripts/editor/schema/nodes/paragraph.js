// @flow

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'
import { setBlockType } from 'prosemirror-commands'

export default class Paragraph extends Node {
  name = 'paragraph'

  get schema() {
    return {
      content: 'inline*',
      group: 'block',
      draggable: false,
      parseDOM: [
        {
          tag: 'p'
        }
      ],
      toDOM: () => ['p', 0]
    }
  }

  commands({ type }: PMNode) {
    return () => setBlockType(type)
  }
}
