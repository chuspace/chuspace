// @flow

import CodeBlockView, { computeChange } from './code-block'
import { Node as ProsemirrorNode, Schema } from 'prosemirror-model'
import { html, render } from 'lit'
import { redo, undo } from 'prosemirror-history'

import type { BaseViewPropType } from './base'
import CodeMirror from 'codemirror'

export default class FrontMatterView extends CodeBlockView {
  constructor(props: BaseViewPropType & { editable: boolean }) {
    // Call super but don't render the view
    super(props, false)

    // Custom attribute for frontmatter element
    this.mode = 'yaml'
    this.node.attrs.language = 'yaml'
    this.content = this.node.textContent
    this.readOnly = props.editable ? false : 'nocursor'

    this.renderElement()
  }

  renderElement = () => {
    const node = document.createElement('div')

    render(
      html`
        <details class="whitespace-nowrap front-matter" as="tab">
          <summary
            class="border font-mono text-base border-base-300 rounded-md p-2 px-4"
            ><span>FrontMatter</span></summary
          >
          <code-editor
            mode=${this.mode}
            readonly="false"
            wrapper="false"
            content=${this.content}
            .onInit=${this.onInit}
            .codeMirrorKeymap=${this.codeMirrorKeymap}
            .onLanguageChange=${this.onLanguageChange}
            .onDestroy=${this.destroy}
          ></code-editor>
        </details>
      `,
      node
    )

    this.containerNode = node.children[0]
    this.dom = this.containerNode
  }

  selectNode = () => {
    this.containerNode.open = true
    this.cm.focus()
  }
}
