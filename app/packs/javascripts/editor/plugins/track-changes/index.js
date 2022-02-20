// @flow

import { Commit, emptyCommit } from './commit'
import { EditorState, Plugin, PluginKey } from 'prosemirror-state'

import { Element } from 'editor/base'
import { Node as ProsemirrorNode } from 'prosemirror-model'

export interface TrackPluginState {
  config: {
    ancestorDoc: ProsemirrorNode | null
  };
  commit: Commit;
}

interface TrackPluginConfig {
  commit?: Commit;
  ancestorDoc?: ProsemirrorNode;
}

const trackPlugin: Plugin<TrackPluginState> = new Plugin({
  key: new PluginKey('track-changes-plugin'),

  state: {
    init(): TrackPluginState {
      return {
        config: {
          ancestorDoc: ancestorDoc || null
        },
        commit: commit || emptyCommit()
      }
    },

    apply(tr, state: TrackPluginState) {
      return applyAction(state, tr)
    }
  }
})

export default class TrackChange extends Element {
  name = 'track-changes'

  get plugins() {
    return [trackPlugin]
  }
}

export const getTrackPluginState = (state: EditorState) =>
  trackPluginKey.getState(state)
