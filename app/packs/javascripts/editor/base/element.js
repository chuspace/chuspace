// @flow

import { Node } from 'prosemirror-model'

export default class Element {
  options: any
  name: ?string
  editor: any
  mode: any

  get type() {
    return 'element'
  }

  get defaultOptions() {
    return {}
  }

  init() {
    return null
  }

  constructor(options: {} = {}) {
    this.options = {
      ...this.defaultOptions,
      ...options
    }
  }

  bindEditor(editor: any = null) {
    this.editor = editor
  }

  get update() {
    return () => {}
  }

  get plugins() {
    return []
  }

  inputRules(node: Node) {
    return []
  }

  pasteRules(node: Node) {
    return []
  }

  keys(node: Node) {
    return {}
  }
}
