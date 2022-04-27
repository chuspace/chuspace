// @flow

import { Element, Node } from 'editor/base'
import { Fragment, Node as PMNode, Schema } from 'prosemirror-model'
import { Plugin, PluginKey, Selection } from 'prosemirror-state'
import { calcYchangeDomAttrs, hoverWrapper } from 'editor/helpers'
import { nodeInputRule, toggleBlockType } from 'editor/commands'

import pick from 'lodash.pick'
import { setBlockType } from 'prosemirror-commands'

const removeLastNewLine = (dom: HTMLElement): HTMLElement => {
  const parent = dom && dom.parentElement
  if (parent && parent.classList.contains('codehilite')) {
    dom.textContent = dom.textContent.replace(/\n$/, '')
  }
  return dom
}

export default class CodeBlock extends Node {
  name = 'code_block'

  get schema(): PMNode {
    return {
      content: 'text*',
      attrs: {
        language: { default: 'auto' },
        class: { default: 'CodeMirror' }
      },
      marks: '',
      group: 'block',
      code: true,
      defining: true,
      isolating: true,
      draggable: false,
      parseDOM: [
        {
          tag: 'pre',
          preserveWhitespace: 'full',
          getAttrs: (domNode: PMNode) => {
            let dom = domNode
            const language = dom.getAttribute('data-language')
            dom = removeLastNewLine(dom)
            return { language }
          }
        },
        // Handle VSCode paste
        // Checking `white-space: pre-wrap` is too aggressive @see ED-2627
        {
          tag: 'div[style]',
          preserveWhitespace: 'full',
          getAttrs: (dom: PMNode) => {
            if (dom.style.whiteSpace === 'pre') {
              return {}
            }
            return false
          },
          // @see ED-5682
          getContent: (domNode: PMNode, schema: Schema) => {
            const dom = domNode
            const code = Array.from(dom.children)
              .map((child) => child.textContent)
              .filter((x) => x !== undefined)
              .join('\n')
            return code ? Fragment.from(schema.text(code)) : Fragment.empty
          }
        },
        // Handle GitHub/Gist paste
        {
          tag: 'table[style]',
          preserveWhitespace: 'full',
          getAttrs: (dom: PMNode) => {
            if (dom.querySelector('td[class*="blob-code"]')) {
              return {}
            }
            return false
          }
        },
        {
          tag: 'div.code-block',
          preserveWhitespace: 'full',
          getAttrs: (dom: PMNode) => {
            // TODO: ED-5604 Fix it inside `react-syntax-highlighter`
            // Remove line numbers
            const linesCode = dom.querySelector('code')
            if (
              linesCode &&
              linesCode.querySelector('.react-syntax-highlighter-line-number')
            ) {
              // It's possible to copy without the line numbers too hence this
              // `react-syntax-highlighter-line-number` check, so that we don't remove real code
              linesCode.remove()
            }
            return {}
          }
        }
      ],
      toDOM(node) {
        return ['pre', ['code', node.attrs, 0]]
      }
    }
  }

  commands({ type, schema }: PMNode) {
    return () => toggleBlockType(type, schema.nodes.paragraph)
  }

  keys({ type }: PMNode) {
    return {
      'Shift-Ctrl-\\': setBlockType(type)
    }
  }

  get plugins() {
    return [
      new Plugin({
        key: new PluginKey('code_block'),
        props: {
          handleKeyDown(view, event) {
            if (event.keyCode === 13) {
              const { state } = view
              const { schema, tr } = state

              if (!state.selection.$cursor) {
                return false
              }

              const { nodeBefore, pos } = state.selection.$from

              if (!nodeBefore || !nodeBefore.isText) {
                return false
              }

              const regex = /^```([a-zA-Z]*)?$/
              const matches = nodeBefore.text.match(regex)

              if (matches) {
                const [, language] = matches

                const { tr } = state

                const from = pos - matches[0].length
                const to = pos
                const text = matches[0]

                if (matches[0]) {
                  const node = schema.nodes.code_block.create({
                    language
                  })

                  tr.replaceWith(pos - matches[0].length - 1, pos, node)
                    .setMeta(this, {
                      transform: tr,
                      from,
                      to,
                      text
                    })
                    .scrollIntoView()

                  view.dispatch(tr)

                  return true
                }
              }
            }

            return false
          }
        }
      })
    ]
  }
}
