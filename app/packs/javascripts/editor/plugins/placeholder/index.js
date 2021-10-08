// @flow

import { Decoration, DecorationSet, EditorView } from 'prosemirror-view'

import { Element } from 'editor/base'
import { Node } from 'prosemirror-model'
import { Plugin } from 'prosemirror-state'
import includes from 'lodash/includes'

export default class Placeholder extends Element {
  name = 'placeholder'

  get update() {
    return (view: EditorView) => {
      view.updateState(view.state)
    }
  }

  get plugins() {
    return [
      new Plugin({
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
              const hasPlaceholder = includes(
                ['paragraph', 'heading'],
                node.type.name
              )

              if (!hasPlaceholder) {
                return
              }

              if (doc.childCount <= 1) {
                decorations.push(
                  Decoration.node(pos, pos + node.nodeSize, {
                    class: 'body__empty',
                    'data-empty-text': 'Write your article here...'
                  })
                )
              }

              if (node.type.name == 'heading') {
                let text = `h${node.attrs.level}`

                decorations.push(
                  Decoration.node(pos, pos + node.nodeSize, {
                    class: 'heading',
                    'data-text': text
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
