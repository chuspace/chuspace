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
    let content = 'front_matter* block+'

 

    switch (this.editor.mode) {
      case 'contribution':
        let node = this.editor.contribution.node.type || 'paragraph'
        content = `${this.editor.contribution.node.type}+`
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
