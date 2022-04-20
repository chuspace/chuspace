// @flow

import { Decoration, DecorationSet, EditorView } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'
import { html, render, svg } from 'lit'

import { type CollaborationUser } from 'editor/collaboration'
import ContributionItem from './item'
import { Element } from 'editor/base'
import cssClasses from './constants'
import { customAlphabet } from 'nanoid'
import { renderContributionModal } from './toolbar'

const nanoid = customAlphabet('1234567890abcdef', 10)

export const contributionWidgetName = 'contribution-widget'
export const contributionWidgetKey = new PluginKey(contributionWidgetName)

export type WidgetType = {
  content: string,
  type: string,
  node: {
    type: string,
    meta: {
      lang: ?string
    }
  },
  author: CollaborationUser,
  start: number,
  end: number
}

export function renderNode(contribution: WidgetType) {
  const widget = document.createElement('div')
  widget.className = 'absolute cursor-pointer left-0 top-0 mt-2 -ml-12'

  const template = svg`
        <svg class='fill-current w-6 h-6' xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16"><path fill-rule="evenodd" d="M7.177 3.073L9.573.677A.25.25 0 0110 .854v4.792a.25.25 0 01-.427.177L7.177 3.427a.25.25 0 010-.354zM3.75 2.5a.75.75 0 100 1.5.75.75 0 000-1.5zm-2.25.75a2.25 2.25 0 113 2.122v5.256a2.251 2.251 0 11-1.5 0V5.372A2.25 2.25 0 011.5 3.25zM11 2.5h-1V4h1a1 1 0 011 1v5.628a2.251 2.251 0 101.5 0V5A2.5 2.5 0 0011 2.5zm1 10.25a.75.75 0 111.5 0 .75.75 0 01-1.5 0zM3.75 12a.75.75 0 100 1.5.75.75 0 000-1.5z"></path></svg>
      `

  render(template, widget)

  widget.addEventListener('click', (event) =>
    renderContributionModal(contribution)
  )

  return widget
}

function createContributionWidget(contribution: WidgetType) {
  contribution = { id: nanoid(), ...contribution }
  const nodeDeco = Decoration.node(
    contribution.start,
    contribution.end,
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
          renderNode(contribution),
          contribution
        ),
        nodeDeco
      ]
}

class ContributionState {
  decorations: DecorationSet

  constructor(decos: DecorationSet) {
    this.decorations = decos
  }

  decorationsAt = (start, end) =>
    this.decorations.find(start, end, (spec) => spec.type == 'contribution')

  contributionsWidgetAt = (pos) =>
    this.decorations.find(pos, pos, (spec) => spec.type == 'contribution')

  apply(tr: Transaction) {
    const contribution = tr.getMeta(contributionWidgetKey)
    let set = this.decorations
    set = set.map(tr.mapping, tr.doc)

    if (contribution) {
      const { start, widgetPos } = contribution

      if (contribution.add) {
        set = set.remove(this.decorationsAt(start + 1, widgetPos))
        set = set.add(tr.doc, createContributionWidget(contribution))
      } else if (contribution.remove) {
        set = set.remove(this.decorationsAt(start + 1, widgetPos))
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

    findContributionWidget(state: EditorState, pos: number) {
      return this.getState(state).contributionsWidgetAt(pos)
    }
  }
})

export class ContributionWidget extends Element {
  name = contributionWidgetName

  get plugins() {
    return this.editor.contribution ? [contributionWidget] : []
  }
}
