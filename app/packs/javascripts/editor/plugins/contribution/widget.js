// @flow

import { Decoration, DecorationSet, EditorView } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'

import ContributionItem from './item'
import { Element } from 'editor/base'
import cssClasses from './constants'

export const contributionWidgetName = 'contribution-widget'
export const contributionWidgetKey = new PluginKey(contributionWidgetName)

function createContributionWidget({ fromPos, toPos, oldContent, newContent }) {
  const widget = document.createElement('div')
  widget.className = 'badge absolute left-0 -ml-12'
  widget.textContent = '1'

  return Decoration.widget(fromPos + 1, widget)
}

class ContributionState {
  decorations: DecorationSet

  constructor(decos: DecorationSet) {
    this.decorations = decos
  }

  contributionsAt(pos: number) {
    return this.decorations.find(pos, pos)
  }

  apply(tr: Transaction) {
    const contribution = tr.getMeta(contributionWidgetKey)
    if (!contribution) return this

    console.log(contribution)
    let decos = this.decorations
    decos = decos.map(tr.mapping, tr.doc)

    decos = decos.add(tr.doc, [
      createContributionWidget(contribution),
      Decoration.node(contribution.fromPos, contribution.toPos, {
        class: 'relative revision-node'
      })
    ])

    return new ContributionState(decos)
  }

  static init(state: EditorState) {
    const decos = state.contributions.map((contribution) =>
      createContributionWidget(contribution)
    )

    return new ContributionState(DecorationSet.create(state.doc, decos))
  }
}

const contributionWidget = new Plugin({
  key: contributionWidgetKey,
  state: {
    init: ContributionState.init,
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

export class ContributionWidget extends Element {
  name = contributionWidgetName

  get plugins() {
    return this.editor.contribution ? [contributionWidget] : null
  }
}
