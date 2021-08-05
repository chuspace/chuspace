// @flow

import { ResolvedPos } from 'prosemirror-model'

export default (pos: ?ResolvedPos = null, type: ?ResolvedPos = null) => {
  if (!pos || !type) {
    return false
  }

  const start = pos.parent.childAfter(pos.parentOffset)

  if (!start.node) {
    return false
  }

  const mark = start.node.marks.find((mark) => mark.type === type)

  if (!mark) {
    return false
  }

  let startIndex = pos.index()
  let startPos = pos.start() + start.offset

  while (startIndex > 0 && mark.isInSet(pos.parent.child(startIndex - 1).marks)) {
    startIndex -= 1
    startPos -= pos.parent.child(startIndex).nodeSize
  }

  const endPos = startPos + start.node.nodeSize

  return { from: startPos, to: endPos }
}
