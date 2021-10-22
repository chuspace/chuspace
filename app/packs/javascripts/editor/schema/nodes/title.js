// @flow

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'

export default class Title extends Node {
  name = 'title'

  get schema() {
    return {
      content: 'text*',
      group: 'block',
      defining: true,
      draggable: false,

      parseDOM: [
        {
          tag: 'h1'
        }
      ],
      toDOM: (node: PMNode) => ['h1', 0]
    }
  }
}
