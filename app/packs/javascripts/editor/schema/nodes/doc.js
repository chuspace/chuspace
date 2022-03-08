// @flow

import { Node } from 'editor/base'

export default class Doc extends Node {
  name = 'doc'

  get schema() {
    return {
      content: this.content
    }
  }

  get content() {
    let content = 'front_matter block+'

    switch (this.editor.mode) {
      case 'node':
        let node = this.editor.nodeName || 'paragraph'
        content = `${this.editor.nodeName}`
        break
      case 'comment':
        content = 'block+'
        break
      case 'plain':
        content = 'text+'
        break
      default:
        break
    }

    return content
  }
}
