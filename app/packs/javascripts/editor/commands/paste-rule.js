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

        do {
          match = regexp.exec(text)
          if (match) {
            const start = match.index
            const end = start + match[0].length
            const attrs = getAttrs instanceof Function ? getAttrs(match[0]) : getAttrs

            if (start > 0) {
              nodes.push(child.cut(pos, start))
            }

            nodes.push(child.cut(start, end).mark(markType.create(attrs).addToSet(child.marks)))

            pos = end
          }
        } while (match)

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
