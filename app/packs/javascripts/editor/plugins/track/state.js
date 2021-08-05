// @flow

import { Change, ChangeSet } from 'prosemirror-changeset'
import { EditorState, Transaction } from 'prosemirror-state'

import { Step } from 'prosemirror-transform'

export default class TrackState {
  uncommittedSteps: Array<Step>

  constructor(state: EditorState) {
    this.uncommittedSteps = []
  }

  apply(tr: Transaction) {
    this.uncommittedSteps = this.uncommittedSteps.concat(tr.steps)
    console.log(tr)
    return this
  }
}
