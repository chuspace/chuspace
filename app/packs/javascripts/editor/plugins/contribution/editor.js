// @flow

import { Decoration, DecorationSet } from 'prosemirror-view'
import { Plugin, PluginKey } from 'prosemirror-state'
import { html, render } from 'lit'

import { Element } from 'editor/base'
import { contributionToolbarPluginKey } from './toolbar'
import { contributionWidgetKey } from './widget'

const contributionEditorKey = 'contribution-editor'
export const contributionEditorPluginKey = new PluginKey(contributionEditorKey)

const ContributionEditorPlugin = new Plugin({
  key: contributionEditorPluginKey,
  state: {
    init() {
      return DecorationSet.empty
    },
    apply(tr, value) {
      const contributionMeta = tr.getMeta(contributionToolbarPluginKey)

      if (contributionMeta) {
        const { fromPos, toPos, view, node, content } = contributionMeta

        const onSubmit = (newContent) => {
          delete window[contributionToolbarPluginKey]

          const transaction = view.state.tr.setMeta(
            contributionWidgetKey,
            Object.assign({}, contributionMeta, { newContent })
          )

          view.dispatch(transaction)
        }

        const onStateChange = (state) => {
          window[contributionToolbarPluginKey] = state
        }

        const widget = document.createElement('div')
        widget.textContent = 'foo'
        render(
          html`
            <contribution-modal
              nodeName=${node.type.name}
              editable
              content=${content}
              .onSubmit=${onSubmit}
              .onStateChange=${onStateChange}
            ></contribution-modal>
          `,
          widget
        )

        let nodeDecos

        console.log(fromPos, tr.doc.resolve(fromPos))

        if (node.type.name === 'code_block') {
          nodeDecos = [
            Decoration.node(fromPos, toPos, {}, { widget: widget.children[0] })
          ]
        } else {
          nodeDecos = [
            Decoration.widget(fromPos + 1, widget.children[0]),
            Decoration.node(fromPos, toPos, {
              class: 'relative revision-node'
            })
          ]
        }

        return DecorationSet.create(tr.doc, nodeDecos)
      } else {
        return value ? value.map(tr.mapping, tr.doc) : DecorationSet.empty
      }
    }
  },
  props: {
    decorations(state) {
      return this.getState(state)
    }
  }
})

export class ContributionEditor extends Element {
  name = contributionEditorKey

  get plugins() {
    return this.editor.contribution ? [ContributionEditorPlugin] : []
  }
}
