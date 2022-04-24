// @flow

import { Decoration, DecorationSet, EditorView } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'
import { html, render, svg } from 'lit'

import { type Contribution } from 'editor/collaboration'
import ContributionItem from './item'
import { Element } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'
import { renderContributionModal } from './toolbar'

export const contributionWidgetName = 'contribution-widget'
export const contributionWidgetKey = new PluginKey(contributionWidgetName)

export function renderNode(editor: Editor, contribution: Contribution) {
  const widget = document.createElement('div')
  widget.className =
    'absolute text-secondary hover:text-neutral cursor-pointer left-0 top-0 mt-2 -ml-12'

  const template = svg`
        <svg class='fill-current w-4 h-6' xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16"><path fill-rule="evenodd" d="M7.177 3.073L9.573.677A.25.25 0 0110 .854v4.792a.25.25 0 01-.427.177L7.177 3.427a.25.25 0 010-.354zM3.75 2.5a.75.75 0 100 1.5.75.75 0 000-1.5zm-2.25.75a2.25 2.25 0 113 2.122v5.256a2.251 2.251 0 11-1.5 0V5.372A2.25 2.25 0 011.5 3.25zM11 2.5h-1V4h1a1 1 0 011 1v5.628a2.251 2.251 0 101.5 0V5A2.5 2.5 0 0011 2.5zm1 10.25a.75.75 0 111.5 0 .75.75 0 01-1.5 0zM3.75 12a.75.75 0 100 1.5.75.75 0 000-1.5z"></path></svg>
      `

  render(template, widget)

  widget.addEventListener('click', (event) =>
    renderContributionModal(editor, contribution)
  )

  return widget
}

function createContributionWidget(editor: Editor, contribution: Contribution) {
  const nodeDeco = Decoration.node(
    contribution.posFrom,
    contribution.posTo,
    {
      class: 'relative'
    },
    contribution
  )

  return contribution.node.type === 'code_block'
    ? [nodeDeco]
    : [
        Decoration.widget(
          contribution.widgetPos,
          renderNode(editor, contribution),
          contribution
        ),
        nodeDeco
      ]
}

class ContributionState {
  decorations: DecorationSet

  constructor(editor: Editor, decos: DecorationSet) {
    this.editor = editor
    this.decorations = decos
  }

  decorationsAt = (posFrom, end) => this.decorations.find(posFrom, end)

  contributionsWidgetAt = (pos) => this.decorations.find(pos, pos)

  apply(tr: Transaction) {
    const contributionMeta = tr.getMeta(contributionWidgetKey)
    let set = this.decorations
    set = set.map(tr.mapping, tr.doc)

    if (contributionMeta) {
      if (contributionMeta.reload) {
        return ContributionState.drawContributions(
          tr.doc,
          this.editor,
          contributionMeta.contributions
        )
      }

      const { posFrom, widgetPos } = contributionMeta

      if (contributionMeta.add) {
        set = set.remove(this.decorationsAt(posFrom + 1, widgetPos))
        set = set.add(
          tr.doc,
          createContributionWidget(this.editor, contributionMeta)
        )
      } else {
        set = set.remove(this.decorationsAt(posFrom + 1, widgetPos))
      }
    }

    return new ContributionState(this.editor, set)
  }

  static drawContributions(doc, editor, contributions) {
    let set = DecorationSet.empty

    contributions.map((contribution) => {
      set = set.add(doc, createContributionWidget(editor, contribution))
    })

    return new ContributionState(editor, set)
  }

  static init(config: EditorState, state: Editor) {
    return ContributionState.drawContributions(
      state.doc,
      state.editor,
      config.contributions
    )
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

    findContributionWidget(state: EditorState, pos: number) {
      return this.getState(state).contributionsWidgetAt(pos)
    }
  }
})

export class ContributionWidget extends Element {
  name = contributionWidgetName
  contribution: boolean = true

  get plugins() {
    return this.editor.contribution ? [contributionWidget] : []
  }
}
