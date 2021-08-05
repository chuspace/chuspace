// @flow

import Element from './element'

export default class Mark extends Element {
  constructor(options: {} = {}) {
    super(options)
  }

  get type() {
    return 'mark'
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
