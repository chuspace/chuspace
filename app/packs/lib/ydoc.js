// @flow

import * as marks from 'editor/schema/marks'
import * as nodes from 'editor/schema/nodes'

import { Buffer } from 'buffer'
import { Schema } from 'prosemirror-model'
import {
  encodeStateAsUpdateV2,
  encodeSnapshotV2,
  snapshot,
  PermanentUserData
} from 'yjs'
import { filterElementsBy } from 'editor/helpers'
import { markdownParser } from 'editor/markdowner'
import { prosemirrorToYDoc } from 'y-prosemirror'
import toArray from 'lodash.toarray'
import { toBase64 } from 'lib0/buffer'

global.Buffer = Buffer

const toYDoc = (markdown, username) => {
  const options = {
    excludeFrontmatter: false,
    mode: 'default',
    editable: true
  }

  const elements = [
    ...toArray(marks).map((Mark) => new Mark(options)),
    ...toArray(nodes).map((Node) => new Node(options))
  ]

  elements.forEach((element) => {
    element.bindEditor(options)
    element.init()
  })

  const pmSchema = new Schema({
    nodes: filterElementsBy(elements, 'node'),
    marks: filterElementsBy(elements, 'mark')
  })

  const contentParser = markdownParser(pmSchema)
  const pmDoc = contentParser.parse(markdown)
  const ydoc = prosemirrorToYDoc(pmDoc)

  const permanentUserData = new PermanentUserData(ydoc)
  permanentUserData.setUserMapping(ydoc, ydoc.clientID, username)
  const versions = ydoc.getArray('versions')

  versions.push([
    {
      date: new Date().getTime(),
      snapshot: encodeSnapshotV2(snapshot(ydoc)),
      clientID: ydoc.clientID
    }
  ])

  return toBase64(encodeStateAsUpdateV2(ydoc))
}

export default toYDoc

global.toYDoc = toYDoc
