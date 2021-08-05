// @flow

import { Element } from 'editor/base'
import { Plugin } from 'prosemirror-state'
import TrackState from './state'

export default class Track extends Element {
  name = 'track'

  get plugins() {
    return [
      new Plugin({
        state: {
          init(state, instance) {
            return new TrackState(state)
          },
          apply(tr, tracked) {
            return tracked.apply(tr)
          }
        }
      })
    ]
  }
}
