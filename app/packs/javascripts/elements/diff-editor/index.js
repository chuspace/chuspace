// @flow

import 'codemirror/mode/diff/diff'

import * as CodeMirror from 'codemirror'
import * as Diff from 'diff'

import { attr, controller, target } from '@github/catalyst'

@controller
export default class DiffEditor extends HTMLElement {
  @attr filepath: string = ''
  @attr initialContent: string = ''
  @attr newContent: string = ''
  @target codemirror: HTMLElement
  diffEditor: CodeMirror
  diff: string

  connectedCallback() {
    this.diffEditor = CodeMirror.fromTextArea(this.codemirror, {
      theme: 'chuspace-dark',
      lineNumbers: true,
      readOnly: true,
      indentUnit: 2,
      mode: 'diff',
      lineWrapping: true,
      addModeClass: true
    })
  }

  attributeChangedCallback(
    name: string,
    oldValue: string | null,
    newValue: string | null
  ): void {
    if (name == 'data-new-content' && newValue) {
      this.calculateDiff(this.initialContent, newValue)
    }
  }

  calculateDiff = (oldValue, newValue) => {
    this.diffEditor.setValue(
      Diff.createPatch(this.filepath, oldValue, newValue, '', '', {
        context: 3
      })
    )
  }
}
