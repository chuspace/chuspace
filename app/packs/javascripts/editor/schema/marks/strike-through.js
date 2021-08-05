// @flow

import { markInputRule, markPasteRule } from 'editor/commands'

import { Mark } from 'editor/base'
import { Mark as PMMark } from 'prosemirror-model'
import { toggleMark } from 'prosemirror-commands'

export default class StrikeThrough extends Mark {
  name = 'strike_through'

  get schema() {
    return {
      parseDOM: [
        {
          tag: 's'
        },
        {
          tag: 'del'
        },
        {
          tag: 'strike'
        },
        {
          style: 'text-decoration',
          getAttrs: (value: string) => value === 'line-through'
        }
      ],
      toDOM: () => ['s', 0]
    }
  }

  keys({ type }: PMMark) {
    return {
      'Mod-d': toggleMark(type)
    }
  }

  commands({ type }: PMMark) {
    return () => toggleMark(type)
  }

  inputRules({ type }: PMMark) {
    return [markInputRule(/~([^~]+)~$/, type)]
  }

  pasteRules({ type }: PMMark) {
    return [markPasteRule(/~([^~]+)~/g, type)]
  }
}
