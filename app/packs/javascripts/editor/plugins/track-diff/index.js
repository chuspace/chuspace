// @flow

import { Decoration, DecorationSet, EditorView } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey, Transaction } from 'prosemirror-state'

import { Change } from 'prosemirror-changeset'
import { Element } from 'editor/base'

const findDeleteEndIndex = (startIndex: number, changes: Array<Change>) => {
  for (let i = startIndex; i < changes.length; i++) {
    // if we are at the end then that's the end index
    if (i === changes.length - 1) return i
    // if the next change is discontinuous then this is the end index
    if (changes[i].toB + 1 !== changes[i + 1].fromB) return i
  }
}

const findInsertEndIndex = (startIndex: number, changes: Array<Change>) => {
  for (let i = startIndex; i < changes.length; i++) {
    // if we are at the end then that's the end index
    if (i === changes.length - 1) return i
    // if the next change is discontinuous then this is the end index
    if (changes[i].toA + 1 !== changes[i + 1].fromA) return i
  }
}

export const TrackDiffPlugin = new Plugin({
  key: new PluginKey('diffs'),
  props: {
    decorations(state) {
      let decorations = []
      let index = 0

      while (index < changes.length) {
        let endIndex = findDeleteEndIndex(index, changes)
        decorations.push(Decoration.inline(changes[index].fromB, changes[endIndex].toB, { class: 'deletion' }, {}))
        index = endIndex + 1
      }

      index = 0
      while (index < changes.length) {
        let endIndex = findInsertEndIndex(index, changes)

        let slice = tr.doc.slice(changes[index].fromA, changes[endIndex].toA)
        let span = document.createElement('span')
        span.setAttribute('class', 'insertion')
        span.appendChild(DOMSerializer.fromSchema(this._schema).serializeFragment(slice.content))
        decorations.push(
          Decoration.widget(changes[index].toB, span, {
            marks: []
          })
        )

        index = endIndex + 1
      }

      return DecorationSet.create(state.doc, decorations)
    }
  }
})

export default class Highlight extends Element {
  name = 'diffs'

  get plugins() {
    return [TrackDiffPlugin]
  }
}
