// @flow

import { Decoration, DecorationSet } from 'prosemirror-view'
import { Plugin, PluginKey } from 'prosemirror-state'
import { setBlockType, toggleBlockType } from 'editor/commands'

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'
import { findParentNodeOfType } from 'prosemirror-utils'
import { textblockTypeInputRule } from 'prosemirror-inputrules'

type Options = {
  levels: Array<number>
}

export default class Heading extends Node {
  name = 'heading'

  options: Options = {
    levels: [1, 2, 3, 4, 5, 6]
  }

  get schema() {
    return {
      attrs: {
        level: {
          default: 1
        }
      },
      content: 'text*',
      group: 'block',
      defining: true,
      draggable: false,
      // $FlowFixMe
      parseDOM: this.options.levels.map((level: number) => ({
        tag: `h${level}`,
        attrs: { level }
      })),
      toDOM: (node: PMNode) => [`h${node.attrs.level}`, 0]
    }
  }

  commands({ type, schema }: PMNode) {
    return (attrs: {}) => toggleBlockType(type, schema.nodes.paragraph, attrs)
  }

  keys({ type }: PMNode) {
    return this.options.levels.reduce(
      (items, level) => ({
        ...items,
        ...{
          [`Shift-Ctrl-${level}`]: setBlockType(type, { level })
        }
      }),
      {}
    )
  }

  inputRules({ type }: PMNode) {
    // $FlowFixMe
    return this.options.levels.map((level) =>
      textblockTypeInputRule(new RegExp(`^(#{1,${level}})\\s$`), type, () => ({
        level
      }))
    )
  }

  get plugins() {
    return [
      new Plugin({
        key: new PluginKey('headingPlaceholder'),
        props: {
          handleKeyDown: (view, event) => {
            const { schema, doc, tr, selection } = view.state
            const parent = findParentNodeOfType(schema.nodes.heading)(selection)

            if (!parent) return
            if (!parent.node) return

            if (event.code === 'Backspace' && parent.node.content.size === 1) {
              view.props.commands.heading({})
              return true
            }

            return false
          },
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
              if (node.type.name !== 'heading') return

              let text = decorations.push(
                Decoration.node(pos, pos + node.nodeSize, {
                  class: 'heading',
                  'data-text': `h${node.attrs.level}`
                })
              )
            })

            return DecorationSet.create(doc, decorations)
          }
        }
      })
    ]
  }
}
