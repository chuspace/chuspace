// @flow

import { Decoration, DecorationSet, EditorView } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'

import { Element } from 'editor/base'
import HighlightItem from './item'
import cssClasses from './constants'

function createInlineDecoration(from, to, highlight) {
  return Decoration.inline(from, to, { class: cssClasses[highlight.type] }, { highlight })
}

class HighlightState {
  decorations: DecorationSet

  constructor(decos: DecorationSet) {
    this.decorations = decos
  }

  highlightsAt(pos: number) {
    return this.decorations.find(pos, pos)
  }

  apply(tr: Transaction) {
    const action = tr.getMeta('highlight')
    if (!action) return this

    const { fromPos, toPos } = tr.getMeta('highlight')
    let decos = this.decorations
    decos = decos.map(tr.mapping, tr.doc)

    if (action.action == 'add') {
      if (!action.type) return this
      decos = decos.add(tr.doc, [Decoration.inline(fromPos, toPos, { class: cssClasses[action.type] })])
    } else if (action.action == 'remove') {
      decos = decos.remove(this.highlightsAt(fromPos))
    }

    return new HighlightState(decos)
  }

  static init(state: EditorState) {
    const decos = state.highlights.map((c) => createInlineDecoration(c.from, c.to, new HighlightItem(c.action, c.type)))
    return new HighlightState(DecorationSet.create(state.doc, decos))
  }
}

export const highlightPlugin = new Plugin({
  key: new PluginKey('highlight'),
  state: {
    init: HighlightState.init,
    apply(tr, prev) {
      return prev.apply(tr)
    }
  },
  props: {
    decorations(state) {
      return this.getState(state).decorations
    }
  }
})

export default class Highlight extends Element {
  name = 'highlight'

  get plugins() {
    return [highlightPlugin]
  }
}
