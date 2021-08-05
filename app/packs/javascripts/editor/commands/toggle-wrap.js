// @flow

import { EditorState, Transaction } from 'prosemirror-state'
import { lift, wrapIn } from 'prosemirror-commands'

import { EditorView } from 'prosemirror-view'
import { isNodeActive } from 'editor/helpers'

export default function(type: string) {
  return (state: EditorState, dispatch: Transaction, view: EditorView) => {
    const isActive = isNodeActive(state, type)

    if (isActive) {
      return lift(state, dispatch)
    }

    return wrapIn(type)(state, dispatch, view)
  }
}
