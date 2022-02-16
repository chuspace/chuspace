// @flow

import { Plugin, PluginKey } from 'prosemirror-state'

import { Element } from 'editor/base'
import { Node } from 'prosemirror-model'
import { nodeEqualsType } from 'editor/helpers'

export default class TrailingNode extends Element {
  name = 'trailing_node'

  get defaultOptions() {
    return {
      node: 'paragraph',
      notAfter: ['paragraph', 'blockquote']
    }
  }

  get plugins() {
    const plugin = new PluginKey(this.name)
    const disabledNodes = Object.entries(this.editor.schema.nodes)
      .map(([, value]) => value)
      .filter((node: Node) => this.options.notAfter.includes(node.name))

    return [
      new Plugin({
        key: plugin,
        view: () => ({
          update: (view) => {
            const { state } = view

            const insertNodeAtEnd = plugin.getState(state)

            if (!insertNodeAtEnd) {
              return
            }

            const { doc, schema, tr } = state
            const type = schema.nodes[this.options.node]
            const transaction = tr.insert(doc.content.size, type.create())
            view.dispatch(transaction)
          }
        }),
        state: {
          init: (_, state) => {
            const lastNode = state.tr.doc.lastChild
            const hasTrailingNode = !nodeEqualsType({
              node: lastNode,
              types: disabledNodes
            })
            const isImageNode =
              lastNode.type.name === 'paragraph' &&
              lastNode.firstChild &&
              lastNode.firstChild.type.name === 'image'

            return hasTrailingNode || isImageNode
          },

          apply: (tr, value) => {
            if (!tr.docChanged) {
              return value
            }

            const lastNode = tr.doc.lastChild

            const hasTrailingNode = !nodeEqualsType({
              node: lastNode,
              types: disabledNodes
            })
            const isImageNode =
              lastNode.type.name === 'paragraph' &&
              lastNode.firstChild &&
              lastNode.firstChild.type.name === 'image'

            return hasTrailingNode || isImageNode
          }
        }
      })
    ]
  }
}
