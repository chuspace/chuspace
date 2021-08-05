// @flow

import { chainCommands, exitCode } from 'prosemirror-commands'

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'

export default class HardBreak extends Node {
  name = 'hard_break'

  get schema() {
    return {
      inline: true,
      group: 'inline',
      selectable: false,
      parseDOM: [{ tag: 'br' }],
      toDOM: () => ['br']
    }
  }

  keys({ type }: PMNode) {
    const command = chainCommands(exitCode, (state, dispatch) => {
      dispatch(state.tr.replaceSelectionWith(type.create()).scrollIntoView())
      return true
    })

    return {
      'Mod-Enter': command,
      'Shift-Enter': command
    }
  }
}
