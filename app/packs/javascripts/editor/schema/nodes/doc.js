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
    let content = 'block+'

    switch (this.options.appearance) {
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
