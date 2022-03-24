// @flow

import { Mark } from 'editor/base'
import { hoverWrapper } from 'editor/helpers'

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
            ychange_type: dom.attrs.type
          },
          ...hoverWrapper(dom.attrs, [0])
        ]
      }
    }
  }
}
