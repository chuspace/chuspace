// @flow

import { InputRule } from 'prosemirror-inputrules'
import { Mark } from 'prosemirror-model'

export default function(regexp: RegExp, markType: Mark, getAttrs: Function | {}) {
  return new InputRule(regexp, (state, match, start, end) => {
    const attrs = getAttrs instanceof Function ? getAttrs(match) : getAttrs
    const { tr } = state
    let markEnd = end

    if (match[1]) {
      const startSpaces = match[0].search(/\S/)
      const textStart = start + match[0].indexOf(match[1])
      const textEnd = textStart + match[1].length
      if (textEnd < end) {
        tr.delete(textEnd, end)
      }
      if (textStart > start) {
        tr.delete(start + startSpaces, textStart)
      }
      markEnd = start + startSpaces + match[1].length
    }

    tr.addMark(start, markEnd, markType.create(attrs))
    tr.removeStoredMark(markType)
    return tr
  })
}
