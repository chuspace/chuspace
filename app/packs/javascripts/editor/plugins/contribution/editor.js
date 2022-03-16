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
        const { fromPos, toPos, nodeName, view, content } = contributionMeta

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
          console.log(state)
        }

        const widget = document.createElement('div')

        render(
          html`
            <contribution-modal
              nodeName=${nodeName}
              content=${content}
              .onSubmit=${onSubmit}
              .onStateChange=${onStateChange}
            ></contribution-modal>
          `,
          widget
        )

        return DecorationSet.create(tr.doc, [
          Decoration.widget(toPos - 1, widget.children[0]),
          Decoration.node(fromPos, toPos, {
            class: 'relative revision-node'
          })
        ])
      } else {
        return value ? value.map(tr.mapping, tr.doc) : DecorationSet.empty
      }
    }
  },
  props: {
    decorations(state) {
      return ContributionEditorPlugin.getState(state)
    }
  }
})

export class ContributionEditor extends Element {
  name = contributionEditorKey

  get plugins() {
    return this.editor.contribution ? [ContributionEditorPlugin] : null
  }
}
