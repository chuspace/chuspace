// @flow

import { Decoration, DecorationSet, EditorView } from 'prosemirror-view'

import { Element } from 'editor/base'
import { Node } from 'prosemirror-model'
import { Plugin } from 'prosemirror-state'

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
          decorations: ({ doc, plugins }) => {
            const editablePlugin = plugins.find((plugin) =>
              plugin.key.startsWith('editable$')
            )
            const editable = editablePlugin.props.editable()

            if (!editable) {
              return false
            }

            const decorations = []

            if (doc.content.size === 2) {
              decorations.push(
                Decoration.node(0, 2, {
                  class: 'body body__label body__label__empty',
                  'data-empty-text': 'Write your post...'
                })
              )
            }

            return DecorationSet.create(doc, decorations)
          }
        }
      })
    ]
  }
}
