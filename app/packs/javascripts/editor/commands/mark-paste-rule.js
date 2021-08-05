// @flow

import { Fragment, Slice } from 'prosemirror-model'

import { Mark } from 'editor/base'
import { Plugin } from 'prosemirror-state'

export default function(regexp: RegExp, markType: Mark, getAttrs: Function | {}) {
  const handler = fragment => {
    const nodes = []

    fragment.forEach(child => {
      if (child.isText) {
        const { text } = child
        let pos = 0
        let match

        // eslint-disable-next-line
        while ((match = regexp.exec(text)) !== null) {
          if (match && match[1]) {
            const start = match.index
            const end = start + match[0].length
            const textStart = start + match[0].indexOf(match[1])
            const textEnd = textStart + match[1].length
            const attrs = getAttrs instanceof Function ? getAttrs(match) : getAttrs

            // adding text before markdown to nodes
            if (start > 0) {
              nodes.push(child.cut(pos, start))
            }

            // adding the markdown part to nodes
            nodes.push(child.cut(textStart, textEnd).mark(markType.create(attrs).addToSet(child.marks)))

            pos = end
          }
        }

        // adding rest of text to nodes
        if (pos < text.length) {
          nodes.push(child.cut(pos))
        }
      } else {
        nodes.push(child.copy(handler(child.content)))
      }
    })

    return Fragment.fromArray(nodes)
  }

  return new Plugin({
    props: {
      transformPasted: slice => new Slice(handler(slice.content), slice.openStart, slice.openEnd)
    }
  })
}
