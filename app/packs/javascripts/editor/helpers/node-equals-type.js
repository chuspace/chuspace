// @flow

import { Node } from 'prosemirror-model'

export default function nodeEqualsType({
  types,
  node
}: {
  types: Array<Node>,
  node: Node
}) {
  return (
    (Array.isArray(types) && types.includes(node.type)) || node.type === types
  )
}
