// @flow

import 'codemirror/mode/yaml/yaml'
import 'codemirror/mode/yaml-frontmatter/yaml-frontmatter'
import 'codemirror/addon/display/autorefresh'

import * as CodeMirror from 'codemirror'

import { controller, target, targets } from '@github/catalyst'

@controller
export default class FrontmatterEditor extends HTMLElement {
  connectedCallback() {
    this.codemirror = CodeMirror.fromTextArea(this.querySelector('textarea'), {
      mode: 'yaml-frontmatter',
      theme: `chuspace-${window.colorScheme}`,
      styleActiveLine: true,
      smartIndent: !this.readonly,
      readOnly: this.readonly || false,
      indentUnit: 2,
      lineWrapping: true,
      addModeClass: true
    })
  }

  toggle() {
    setTimeout(() => this.codemirror.refresh(), 200)
    this.codemirror.focus()
  }

  createRenderRoot() {
    return this
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('frontmatter-editor')) {
    customElements.define('frontmatter-editor', FrontmatterEditor)
  }
})
