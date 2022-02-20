// @flow

import 'codemirror/mode/diff/diff'

import * as CodeMirror from 'codemirror'

import { attr, controller, target } from '@github/catalyst'

@controller
export default class DiffEditor extends HTMLElement {
  connectedCallback() {
    this.diffEditor = CodeMirror.fromTextArea(this.querySelector('textarea'), {
      theme: 'chuspace-dark',
      lineNumbers: true,
      readOnly: true,
      indentUnit: 2,
      mode: 'diff',
      lineWrapping: true,
      addModeClass: true
    })
  }
}
