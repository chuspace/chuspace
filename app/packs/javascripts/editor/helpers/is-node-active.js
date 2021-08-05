// @flow

import { EditorState } from 'prosemirror-state'
import findParentNode from './find-parent-node'

export default function(state: EditorState, type: string, attrs: {} = {}) {
  const predicate = node => node.type === type
  const parent = findParentNode(predicate)(state.selection)

  if (!Object.keys(attrs).length || !parent) {
    return !!parent
  }

  return parent.node.hasMarkup(type, attrs)
}
