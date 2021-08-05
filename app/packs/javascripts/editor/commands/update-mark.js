// @flow

import { EditorState, Transaction } from 'prosemirror-state'

import { Mark } from 'editor/helpers'

export default function(type: Mark, attrs: {}) {
  return (state: EditorState, dispatch: Transaction) => {
    const { from, to } = state.selection
    return dispatch(state.tr.addMark(from, to, type.create(attrs)))
  }
}
