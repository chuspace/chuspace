// @flow

import { Decoration, DecorationSet } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey } from 'prosemirror-state'
import { html, render } from 'lit'

import { Element } from 'editor/base'
import { markdownSerializer } from 'editor/markdowner'

type Options = {
  nodes: Array<string>
}

export const contributionToolbarKey = 'contribution-toolbar'
export const contributionToolbarPluginKey = new PluginKey(
  contributionToolbarKey
)

export class ContributionToolbar extends Element {
  name = contributionToolbarKey

  options: Options = {
    allowedNodes: ['paragraph']
  }

  get plugins() {
    const options = this.options

    return this.editor.contribution
      ? [
          new Plugin({
            key: contributionToolbarPluginKey,
            state: {
              init() {
                return DecorationSet.empty
              },
              apply(tr, value) {
                const contributionMeta = tr.getMeta(
                  contributionToolbarPluginKey
                )

                if (contributionMeta) {
                  const {
                    fromPos,
                    toPos,
                    view,
                    node,
                    content
                  } = contributionMeta

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

                  return DecorationSet.create(tr.doc, [
                    Decoration.widget(fromPos + 1, widget.children[0]),
                    Decoration.node(fromPos, toPos, {
                      class: 'relative revision-node'
                    })
                  ])
                } else {
                  return value
                    ? value.map(tr.mapping, tr.doc)
                    : DecorationSet.empty
                }
              }
            },

            props: {
              decorations(state) {
                return this.getState(state)
              },
              handleDOMEvents: {
                mouseover(view, event) {
                  if (window[contributionToolbarPluginKey]) return

                  const pos = view.posAtCoords({
                    left: event.clientX,
                    top: event.clientY
                  })

                  const domAtPos = view.domAtPos(pos.pos)
                  const nodeAtPos = domAtPos?.node?.pmViewDesc?.node
                  const toElementView = event?.toElement?.pmViewDesc
                  const node = toElementView?.node || nodeAtPos
                  const inlineNode =
                    node.type.name === 'paragraph' &&
                    node.content.content.some(
                      (node) => node.type.name !== 'text'
                    )

                  if (inlineNode) {
                    return event
                  }

                  if (node && options.allowedNodes.includes(node.type.name)) {
                    let fromPos = toElementView?.posBefore
                    let toPos = toElementView?.posAfter

                    const content = markdownSerializer(
                      view.props.schema
                    ).serialize(node.content)

                    const transaction = view.state.tr.setMeta(
                      contributionToolbarPluginKey,
                      {
                        node,
                        content,
                        view: view,
                        fromPos,
                        toPos
                      }
                    )

                    view.dispatch(transaction)
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
