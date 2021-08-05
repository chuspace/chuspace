// @flow

import { InputRule } from 'prosemirror-inputrules'
import { Mark } from 'prosemirror-model'

export default function(regexp: RegExp, nodeType: Mark, getAttrs: Function | {}) {
  return new InputRule(regexp, (state, match, start, end) => {
    const attrs = getAttrs instanceof Function ? getAttrs(match) : getAttrs
    const { tr } = state

    if (match[0]) {
      tr.replaceWith(start - 1, end, nodeType.create(attrs))
    }

    return tr
  })
}
