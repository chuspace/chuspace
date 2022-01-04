// @flow

import { Decoration, DecorationSet, EditorView } from 'prosemirror-view'
import { Plugin, PluginKey } from 'prosemirror-state'

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'
import includes from 'lodash/includes'
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

  get plugins() {
    return [
      new Plugin({
        key: new PluginKey('paragraphPlaceholder'),
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
