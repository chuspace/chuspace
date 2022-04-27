// @flow

import { Decoration, DecorationSet } from 'prosemirror-view'
import { Plugin, PluginKey } from 'prosemirror-state'
import { html, render, svg } from 'lit'

import { type Contribution } from 'editor/collaboration'
import { Element } from 'editor/base'
import { contributionWidgetKey } from './widget'
import { customAlphabet } from 'nanoid'

const nanoid = customAlphabet('1234567890abcdef', 10)

type Options = {
  nodes: Array<string>
}

export const contributionToolbarKey = 'contribution-toolbar'
export const contributionToolbarPluginKey = new PluginKey(
  contributionToolbarKey
)

const isMark = (node) => node && node.mark?.type

const findViewNode = (view, event) => {
  const pos = view.posAtCoords({
    left: event.clientX,
    top: event.clientY
  })

  if (pos && pos.inside > -1) {
    const dom = view.domAtPos(pos.pos)
    let node = dom.node.pmViewDesc.node

    switch (node.type.name) {
      case 'paragraph':
        node = node.content.content.find((node) => node.type.name === 'image')
        break
      default:
        break
    }

    return { fromPos: pos.inside, toPos: pos.inside + node.nodeSize, node }
  } else {
    return null
  }
}

export const renderContributionModal = (
  editor: Editor,
  contribution: Contribution
) => {
  const widget = document.createElement('div')

  render(
    html`
      <contribution-node-editor
        .contribution=${contribution}
        .parentEditor=${editor}
      ></contribution-node-editor>
    `,
    widget
  )

  document.body.appendChild(widget)
}

export class ContributionToolbar extends Element {
  name = contributionToolbarKey
  contribution: boolean = true
  options: Options = {
    allowedNodes: ['paragraph', 'code_block']
  }

  get plugins() {
    const editor = this.editor
    const options = this.options

    return editor.contribution
      ? [
          new Plugin({
            key: contributionToolbarPluginKey,
            props: {
              handleDOMEvents: {
                dblclick(view, event) {
                  const pmView = event?.srcElement?.pmViewDesc
                  let node
                  let fromPos
                  let toPos

                  if (pmView) {
                    if (isMark(pmView)) {
                      node = pmView.parent.node
                      if (node.type.name === 'doc') return event
                      fromPos = pmView.parent.posBefore
                      toPos = pmView.parent.posAfter
                    } else {
                      node = pmView.node

                      if (node.type.name === 'doc') return event
                      fromPos = pmView.posBefore
                      toPos = pmView.posAfter
                    }
                  } else {
                    const viewNode = findViewNode(view, event)
                    if (!viewNode) return event
                    if (viewNode.node.type.name === 'doc') return event

                    fromPos = viewNode.fromPos
                    toPos = viewNode.toPos
                    node = viewNode.node
                  }

                  const widgetPos = toPos - 1

                  const contributionPlugin = view.state.plugins.find(
                    (plugin) => plugin.key === contributionWidgetKey.key
                  )

                  const widget = contributionPlugin.props.findContributionWidget(
                    view.state,
                    widgetPos
                  )?.[0]

                  if (widget) {
                    event.preventDefault()
                    event.stopPropagation()

                    return renderContributionModal(editor, widget.type.spec)
                  }

                  if (node && options.allowedNodes.includes(node.type.name)) {
                    event.preventDefault()
                    event.stopPropagation()

                    let content = editor.contentSerializer.serialize(
                      view.state.doc.slice(fromPos, toPos).content
                    )

                    const contribution: Contribution = {
                      contentBefore: content,
                      type: 'contribution',
                      status: 'editing',
                      id: nanoid(),
                      node: node.toJSON(),
                      author: editor.user,
                      widgetPos,
                      posFrom: fromPos,
                      posTo: toPos
                    }

                    renderContributionModal(editor, contribution)
                  }

                  return event
                }
              }
            }
          })
        ]
      : []
  }
}
