// @flow

import {
  collab,
  getVersion,
  receiveTransaction,
  sendableSteps
} from 'prosemirror-collab'

import { Element } from 'editor/base'
import { Step } from 'prosemirror-transform'
import debounce from 'lodash.debounce'

export class Collaboration extends Element {
  name = 'collaboration'

  options = {
    version: 0,
    clientID: Math.floor(Math.random() * 0xffffffff),
    debounce: 250,

    onSendable: (sendable) => {
      console.log(sendable)
      if (getVersion(this.editor.state) > sendable.version) {
        return
      }

      const steps = sendable.steps.map((step) => {
        return {
          step: { ...step, stepType: 'replace' },
          clientID: sendable.clientID,
          version: sendable.version
        }
      })

      const payload = {
        steps,
        version: 1
      }

      console.log(payload)

      this.editor.view.dispatch(
        receiveTransaction(
          this.editor.state,
          payload.steps.map((item) =>
            Step.fromJSON(this.editor.schema, item.step)
          ),
          payload.steps.map((item) => item.clientID)
        )
      )
    }
  }

  get onCreate() {
    this.getSendableSteps = debounce((state) => {
      const sendable = sendableSteps(state)

      if (sendable && this.editor.editable) {
        this.options.onSendable(sendable)
      }
    }, this.options.debounce)

    this.editor.on('transaction', ({ state }) => {
      if (state) this.getSendableSteps(state)
    })
  }

  get plugins() {
    return this.editor.collab
      ? [
          collab({
            version: this.options.version,
            clientID: this.options.clientID
          })
        ]
      : []
  }
}

export { Cursor } from './cursor'
