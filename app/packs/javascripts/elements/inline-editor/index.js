// @flow

import { DOMParser, Schema } from 'prosemirror-model'
import { Decoration, DecorationSet, EditorView } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey } from 'prosemirror-state'
import { attr, controller } from '@github/catalyst'
import { history, redo, undo } from 'prosemirror-history'

import { Placeholder } from 'editor/plugins'
import { baseKeymap } from 'prosemirror-commands'
import docNode from 'editor/schema/nodes/doc'
import { dropCursor } from 'prosemirror-dropcursor'
import { gapCursor } from 'prosemirror-gapcursor'
import { keymap } from 'prosemirror-keymap'
import summary from 'editor/schema/nodes/summary'
import textNode from 'editor/schema/nodes/text'
import title from 'editor/schema/nodes/title'

@controller
export default class InlineEditor extends HTMLElement {
  @attr appearance: string = 'title'
  @attr editable: boolean = true

  connectedCallback() {
    let inlineNode = title

    switch (this.appearance) {
      case 'summary':
        inlineNode = summary
        break
      default:
        break
    }

    const elements = [
      new docNode({ appearance: this.appearance }),
      new textNode(),
      new inlineNode()
    ]

    elements.forEach((element) => {
      element.bindEditor(this)
      element.init()
    })

    const mySchema = new Schema({
      nodes: elements.reduce(
        (nodes, { name, schema }) => ({
          ...nodes,
          [name]: schema
        }),
        {}
      ),
      marks: []
    })

    const titleNode = document.createElement('h1')
    titleNode.textContent = this.querySelector('input').value

    const view = new EditorView(this, {
      state: EditorState.create({
        doc: DOMParser.fromSchema(mySchema).parse(titleNode),
        plugins: [
          history(),
          keymap(baseKeymap),

          new Plugin({
            props: {
              decorations: (state) => {
                const plugins = state.plugins
                const doc = state.doc

                const decorations = []

                doc.descendants((node, pos) => {
                  if (node.type.name == this.appearance) {
                    decorations.push(
                      Decoration.node(pos, pos + node.nodeSize, {
                        class:
                          node.content.size === 0
                            ? `${this.appearance}__empty`
                            : this.appearance,
                        'data-text': this.appearance
                      })
                    )
                  }
                })

                return DecorationSet.create(doc, decorations)
              }
            }
          }),
          dropCursor(),
          gapCursor(),
          keymap({
            'Mod-z': undo,
            'Shift-Mod-z': redo
          })
        ]
      })
    })

    view.dom.style.whiteSpace = 'pre-wrap'
    view.dom.title = `Enter ${this.appearance}`
    view.dom.id = `editor-${this.appearance}`

    view.dom.classList.add(
      `${this.appearance}-editor`,
      this.editable ? 'editable' : 'read-only'
    )

    if (this.appearance === 'title') view.focus()
  }

  createRenderRoot() {
    return this
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('inline-editor')) {
    customElements.define('inline-editor', FrontmatterEditor)
  }
})
