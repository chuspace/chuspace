// @flow

import { Decoration, DecorationSet } from 'prosemirror-view'
import { EditorState, Plugin, PluginKey } from 'prosemirror-state'

import { Element } from 'editor/base'

export default class ImagePlaceholder extends Element {
  name = 'image-placeholder'

  get plugins() {
    return [
      new Plugin({
        key: new PluginKey('image-placeholder'),
        state: {
          init() {
            return DecorationSet.empty
          },
          apply(tr, set) {
            // Adjust decoration positions to changes made by the transaction
            set = set.map(tr.mapping, tr.doc)
            // See if the transaction adds or removes any placeholders
            let action = tr.getMeta(this)
            if (action && action.add) {
              let widget = document.createElement('content-loader')
              widget.setAttribute('type', 'image')
              let deco = Decoration.widget(action.add.pos, widget, { id: action.add.id })
              set = set.add(tr.doc, [deco])
            } else if (action && action.remove) {
              set = set.remove(set.find(null, null, (spec) => spec.id == action.remove.id))
            }

            return set
          }
        },
        props: {
          decorations(state) {
            return this.getState(state)
          },

          findPlaceholder(state: EditorState, id: string) {
            let decos = this.getState(state)
            let found = decos.find(null, null, (spec) => spec.id == id)
            return found.length ? found[0].from : null
          }
        }
      })
    ]
  }
}
