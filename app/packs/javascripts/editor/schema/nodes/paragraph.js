// @flow

import { Decoration, DecorationSet } from 'prosemirror-view'
import { Plugin, PluginKey } from 'prosemirror-state'
import { calcYchangeDomAttrs, hoverWrapper } from 'editor/helpers'

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'
import { setBlockType } from 'prosemirror-commands'

export default class Paragraph extends Node {
  name = 'paragraph'

  get schema() {
    return {
      attrs: {
        ychange: { default: null }
      },
      content: 'inline*',
      group: 'block',
      draggable: false,
      parseDOM: [
        {
          tag: 'p'
        }
      ],
      toDOM(node) {
        // only render changes if no child nodes
        const renderChanges = node.content.size === 0

        const attrs = renderChanges
          ? calcYchangeDomAttrs(node.attrs)
          : node.attrs

        const defChildren = [0]
        const children = renderChanges
          ? hoverWrapper(node.attrs.ychange, defChildren)
          : defChildren

        return ['p', attrs, ...children]
      }
    }
  }

  commands({ type }: PMNode) {
    return () => setBlockType(type)
  }

  get plugins() {
    return [
      new Plugin({
        key: new PluginKey('bodyPlaceholder'),
        props: {
          decorations: (state) => {
            const plugins = state.plugins
            const doc = state.doc

            const editablePlugin = plugins.find((plugin) =>
              plugin.key.startsWith('editable$')
            )
            const editable = editablePlugin.props.editable()

            if (!editable) {
              return false
            }

            const decorations = []

            doc.descendants((node, pos) => {
              if (node.type.name !== 'paragraph') return

              if (doc.childCount <= 1 && node.content.size === 0) {
                decorations.push(
                  Decoration.node(pos, pos + node.nodeSize, {
                    class: 'body-empty',
                    'data-text': 'Start writing...'
                  })
                )
              }
            })

            return DecorationSet.create(doc, decorations)
          }
        }
      })
    ]
  }
}
