// @flow

import { Decoration, DecorationSet, EditorView } from 'prosemirror-view'

import { Element } from 'editor/base'
import { Node } from 'prosemirror-model'
import { Plugin } from 'prosemirror-state'
import includes from 'lodash/includes'

export default class Placeholder extends Element {
  name = 'placeholder'

  options = {
    h1Class: 'title title__label',
    h2Class: 'summary summary__label',
    paragraphClass: 'body body__label',
    h1Text: 'Title',
    h2Text: 'Summary',
    paragraphText: 'Write your post here...'
  }

  get update() {
    return (view: EditorView) => {
      view.updateState(view.state)
    }
  }

  getDecoration(node: Node, pos: number) {
    let option
    let className
    let text

    const suffix = node.childCount === 0 ? '__empty' : ''
    const typePrefix = node.attrs.level ? `h${node.attrs.level}` : 'paragraph'

    className = this.options[`${typePrefix}Class`] + suffix
    text = this.options[`${typePrefix}Text`]

    return Decoration.node(pos, pos + node.nodeSize, {
      class: className,
      'data-empty-text': text
    })
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

            doc.descendants((node, pos) => {
              const [firstChild, secondChild] = doc.content.content
              const hasPlaceholder = includes(
                ['heading', 'paragraph'],
                node.type.name
              )

              if (!hasPlaceholder) {
                return
              }

              const isTitle = firstChild === node && node.attrs.level === 1
              const isSummary = secondChild === node && node.attrs.level === 2
              const isEmptyBody =
                secondChild === node &&
                node.type.name === 'paragraph' &&
                doc.childCount <= 3

              if (isTitle || isSummary || isEmptyBody) {
                decorations.push(this.getDecoration(node, pos))
              } else {
                if (node.type.name == 'heading') {
                  decorations.push(
                    Decoration.node(pos, pos + node.nodeSize, {
                      class: 'editor__heading_label',
                      'data-empty-text': `h${node.attrs.level}`
                    })
                  )
                }
              }
            })

            return DecorationSet.create(doc, decorations)
          }
        }
      })
    ]
  }
}
