// @flow

import { Decoration, DecorationSet } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey } from 'prosemirror-state'

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
    allowedNodes: ['paragraph', 'code_block']
  }

  get plugins() {
    const options = this.options

    return this.editor.contribution
      ? [
          new Plugin({
            key: contributionToolbarPluginKey,
            props: {
              handleDOMEvents: {
                mouseover(view, event) {
                  if (window[contributionToolbarPluginKey]) return

                  const toElementView = event?.toElement?.pmViewDesc
                  const node = toElementView?.node

                  if (node && options.allowedNodes.includes(node.type.name)) {
                    const content = markdownSerializer(
                      view.props.schema
                    ).serialize(
                      view.state.doc.slice(
                        toElementView.posBefore,
                        toElementView.posAfter
                      ).content
                    )

                    const transaction = view.state.tr.setMeta(
                      contributionToolbarPluginKey,
                      {
                        nodeName: node.type.name,
                        content,
                        view: view,
                        fromPos: toElementView.posBefore,
                        toPos: toElementView.posAfter
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
