// @flow

import { markInputRule, markPasteRule } from 'editor/commands'

import { Mark } from 'editor/base'
import { Node } from 'prosemirror-model'
import { Mark as PMMark } from 'prosemirror-model'
import { toggleMark } from 'prosemirror-commands'

export default class Strong extends Mark {
  name = 'strong'

  get schema() {
    return {
      parseDOM: [
        {
          tag: 'strong'
        },
        {
          tag: 'b',
          getAttrs: (mark: PMMark) => mark.style.fontWeight !== 'normal' && null
        },
        {
          style: 'font-weight',
          getAttrs: (value: string) => /^(bold(er)?|[5-9]\d{2,})$/.test(value) && null
        }
      ],
      toDOM: () => ['strong', 0]
    }
  }

  keys({ type }: PMMark) {
    return {
      'Mod-b': toggleMark(type)
    }
  }

  commands({ type }: PMMark) {
    return () => toggleMark(type)
  }

  inputRules({ type }: PMMark) {
    return [markInputRule(/(?:\*\*|__)([^*_]+)(?:\*\*|__)$/, type)]
  }

  pasteRules({ type }: PMMark) {
    return [markPasteRule(/(?:\*\*|__)([^*_]+)(?:\*\*|__)/g, type)]
  }
}
