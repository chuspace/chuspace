// @flow

import { calcYChangeStyle, hoverWrapper } from 'editor/helpers'

import { Mark } from 'editor/base'

export default class YChange extends Mark {
  name = 'ychange'

  get schema() {
    return {
      attrs: {
        user: { default: null },
        type: { default: null },
        color: { default: null }
      },
      inclusive: false,
      parseDOM: [{ tag: 'ychange' }],
      toDOM(dom) {
        return [
          'ychange',
          {
            ychange_user: dom.attrs.user,
            ychange_type: dom.attrs.type,
            style: calcYChangeStyle(dom.attrs),
            ychange_color: dom.attrs.color.light
          },
          ...hoverWrapper(dom.attrs, [0])
        ]
      }
    }
  }
}
