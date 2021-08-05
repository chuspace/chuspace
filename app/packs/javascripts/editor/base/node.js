// @flow

import Element from './element'

export default class Node extends Element {
  constructor(options: {} = {}) {
    super(options)
  }

  get type() {
    return 'node'
  }

  get view() {
    return {}
  }

  get schema() {
    return {}
  }

  command() {
    return () => {}
  }
}
