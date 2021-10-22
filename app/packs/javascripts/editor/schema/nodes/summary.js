// @flow

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'

export default class Summary extends Node {
  name = 'summary'

  get schema() {
    return {
      content: 'text*',
      group: 'block',
      defining: true,
      draggable: false,

      parseDOM: [
        {
          tag: 'h2'
        }
      ],
      toDOM: (node: PMNode) => ['h2', 0]
    }
  }
}
