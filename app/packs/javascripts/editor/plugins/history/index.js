// @flow

import { history, redo, undo } from 'prosemirror-history'

import { Element } from 'editor/base'

export default class History extends Element {
  name = 'history'

  options = {
    depth: '',
    newGroupDelay: ''
  }

  keys() {
    const isMac = typeof navigator !== 'undefined' ? /Mac/.test(navigator.platform) : false
    let keymap = {
      'Mod-z': undo,
      'Shift-Mod-z': redo
    }

    if (!isMac) {
      keymap = Object.assign({}, keymap, { 'Mod-y': redo })
    }

    return keymap
  }

  get plugins() {
    return [
      history({
        depth: this.options.depth,
        newGroupDelay: this.options.newGroupDelay
      })
    ]
  }

  commands() {
    return {
      undo: () => undo,
      redo: () => redo
    }
  }
}
