// @flow

import { markInputRule, markPasteRule } from 'editor/commands'

import { Mark } from 'editor/base'
import { Mark as PMMark } from 'prosemirror-model'
import { toggleMark } from 'prosemirror-commands'

export default class Em extends Mark {
  name = 'em'

  get schema() {
    return {
      parseDOM: [{ tag: 'i' }, { tag: 'em' }, { style: 'font-style=italic' }],
      toDOM: () => ['em', 0]
    }
  }

  keys({ type }: PMMark) {
    return {
      'Mod-i': toggleMark(type)
    }
  }

  commands({ type }: PMMark) {
    return () => toggleMark(type)
  }

  inputRules({ type }: PMMark) {
    return [markInputRule(/(?:^|[^*_])(?:\*|_)([^*_]+)(?:\*|_)$/, type)]
  }

  pasteRules({ type }: PMMark) {
    return [markPasteRule(/(?:^|[^*_])(?:\*|_)([^*_]+)(?:\*|_)/g, type)]
  }
}
