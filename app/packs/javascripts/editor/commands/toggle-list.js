// @flow

import { EditorState, Transaction } from 'prosemirror-state'
import { liftListItem, wrapInList } from 'prosemirror-schema-list'

import { EditorView } from 'prosemirror-view'
import { isNodeActive } from 'editor/helpers'

export default function toggleList(type: string, itemType: string) {
  return (state: EditorState, dispatch: Transaction, view: EditorView) => {
    const isActive = isNodeActive(state, type)

    if (isActive) {
      return liftListItem(itemType)(state, dispatch, view)
    }

    return wrapInList(type)(state, dispatch, view)
  }
}
