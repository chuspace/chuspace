// @flow

import { Decoration, DecorationSet, EditorView } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'
import { html, render } from 'lit'

import ContributionItem from './item'
import { Element } from 'editor/base'
import cssClasses from './constants'
import { renderContributionModal } from './toolbar'

export const contributionWidgetName = 'contribution-widget'
export const contributionWidgetKey = new PluginKey(contributionWidgetName)

function createContributionWidget(contribution) {
  const widget = document.createElement('div')
  widget.className = 'absolute left-0 top-0 -ml-12'
  const template = contribution.author.avatar_url
    ? html`
        <div class="avatar">
          <div class="w-8 rounded-full">
            <img src="${contribution.author.avatar_url}" />
          </div>
        </div>
      `
    : html`
        <div class="avatar placeholder">
          <div class="bg-neutral-focus text-neutral-content rounded-full w-8">
            <span class="text-xs">AA</span>
          </div>
        </div>
      `

  render(template, widget)

  widget.addEventListener('click', (event) =>
    renderContributionModal(contribution)
  )

  return [
    Decoration.widget(contribution.widgetPos, widget, contribution),
    Decoration.node(contribution.start, contribution.end, {
      class: 'relative'
    })
  ]
}

class ContributionState {
  decorations: DecorationSet

  constructor(decos: DecorationSet) {
    this.decorations = decos
  }

  contributionsAt = (pos: number) =>
    this.decorations.find(pos, pos, (spec) => spec.type === 'contribution')

  apply(tr: Transaction) {
    const contribution = tr.getMeta(contributionWidgetKey)
    let set = this.decorations
    set = set.map(tr.mapping, tr.doc)

    if (contribution) {
      if (contribution.add) {
        const widget = this.contributionsAt(contribution.widgetPos)?.[0]
        if (!widget) {
          set = set.add(tr.doc, createContributionWidget(contribution))
        }
      } else if (contribution.remove) {
        set = set.remove(this.contributionsAt(contribution.widgetPos))
      }
    }

    return new ContributionState(set)
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
    },

    findContribution(state: EditorState, pos: number) {
      return this.getState(state).contributionsAt(pos)
    }
  }
})

export class ContributionWidget extends Element {
  name = contributionWidgetName

  get plugins() {
    return this.editor.contribution ? [contributionWidget] : []
  }
}
