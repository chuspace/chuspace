// @flow

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'
import { toggleWrap } from 'editor/commands'
import { wrappingInputRule } from 'prosemirror-inputrules'

export default class FrontMatter extends Node {
  name = 'front_matter'

  get schema() {
    return {
      content: 'text*',
      attrs: {
        data: { default: '' },
        language: { default: 'yaml-frontmatter' }
      },
      marks: '',
      group: 'block',
      code: true,
      defining: true,
      isolating: true,
      draggable: false,
      parseDOM: [
        {
          tag: 'pre',
          preserveWhitespace: 'full'
        }
      ],
      toDOM: (node: PMNode) => {
        console.log(node)

        return ['pre', { language: 'yaml-frontmatter', data: node.attrs.data }]
      }
    }
  }
}
