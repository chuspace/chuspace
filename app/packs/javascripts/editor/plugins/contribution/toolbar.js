// @flow

import { Decoration, DecorationSet } from 'prosemirror-view'
import { Plugin, PluginKey } from 'prosemirror-state'
import { html, render, svg } from 'lit'

import { Element } from 'editor/base'
import { contributionWidgetKey } from './widget'

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

export const renderContributionModal = (contribution) => {
  const widget = document.createElement('div')

  render(
    html`
      <contribution-modal .contribution=${contribution}></contribution-modal>
    `,
    widget
  )

  document.body.appendChild(widget)
}

export class ContributionToolbar extends Element {
  name = contributionToolbarKey

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
                click(view, event) {
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

                    return renderContributionModal(widget.type.spec)
                  }

                  if (node && options.allowedNodes.includes(node.type.name)) {
                    event.preventDefault()
                    event.stopPropagation()

                    // Pass raw content for code blocks
                    let content = editor.contentSerializer.serialize(
                      view.state.doc.slice(fromPos, toPos).content
                    )

                    const meta = {
                      content,
                      type: 'contribution',
                      yDocBase64: null,
                      node: {
                        type: node.type.name,
                        content,
                        meta: {
                          lang: node.attrs.language
                        }
                      },
                      author: editor.collaboration.user,
                      widgetPos,
                      start: fromPos,
                      end: toPos
                    }

                    const contribution = {
                      ...meta,
                      handleAdd: (event, payload) => {
                        event.preventDefault()

                        const transaction = view.state.tr.setMeta(
                          contributionWidgetKey,
                          { ...payload, add: true }
                        )

                        view.dispatch(transaction)
                      },

                      handleRemove: (event) => {
                        event.preventDefault()

                        const transaction = view.state.tr.setMeta(
                          contributionWidgetKey,
                          {
                            remove: true,
                            ...meta
                          }
                        )

                        view.dispatch(transaction)
                      }
                    }

                    renderContributionModal(contribution)
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
