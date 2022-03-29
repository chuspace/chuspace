// @flow

import { EditorState, Transaction } from 'prosemirror-state'

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'
import { nodeInputRule } from 'editor/commands'

export default class HorizontalRule extends Node {
  name = 'horizontal_rule'

  get schema() {
    return {
      group: 'block',
      parseDOM: [{ tag: 'hr' }],
      toDOM: () => ['hr']
    }
  }

  commands({ type }: PMNode) {
    return () => (state: EditorState, dispatch: Transaction) =>
      dispatch(state.tr.replaceSelectionWith(type.create()))
  }

  inputRules({ type }: PMNode) {
    return [nodeInputRule(/^(?:---|___\s|\*\*\*\s)$/, type)]
  }
}
