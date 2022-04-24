// @flow

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'

export default class FrontMatter extends Node {
  name = 'front_matter'

  get schema(): PMNode {
    return this.editor.excludeFrontmatter
      ? {}
      : {
          content: 'text*',
          attrs: { language: { default: 'yaml' } },
          marks: '',
          group: 'block',
          code: true,
          defining: true,
          isolating: true,
          draggable: false,
          parseDOM: [
            {
              tag: 'pre',
              preserveWhitespace: 'full',
              priority: 60
            }
          ],
          toDOM(node: PMNode) {
            return ['pre', ['code', { 'data-language': 'yaml' }, 0]]
          }
        }
  }
}
