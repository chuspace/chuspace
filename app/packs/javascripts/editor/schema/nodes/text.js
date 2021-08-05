// @flow

import { Node } from 'editor/base'

export default class Text extends Node {
  name = 'text'

  get schema() {
    return {
      group: 'inline'
    }
  }
}
