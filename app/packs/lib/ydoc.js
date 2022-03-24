// @flow

import * as marks from 'editor/schema/marks'
import * as nodes from 'editor/schema/nodes'

import {
  Doc,
  PermanentUserData,
  applyUpdateV2,
  encodeSnapshotV2,
  encodeStateAsUpdateV2,
  snapshot
} from 'yjs'
import { fromBase64, toBase64 } from 'lib0/buffer'
import { markdownParser, markdownSerializer } from 'editor/markdowner'
import { prosemirrorToYDoc, yDocToProsemirror } from 'y-prosemirror'

import { Buffer } from 'buffer'
import { Schema } from 'prosemirror-model'
import { filterElementsBy } from 'editor/helpers'
import toArray from 'lodash.toarray'

global.Buffer = Buffer

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

const toYDoc = (markdown, username) => {
  const contentParser = markdownParser(pmSchema)
  const pmDoc = contentParser.parse(markdown)
  const ydoc = prosemirrorToYDoc(pmDoc)
  ydoc.gc = false

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

const fromYDoc = (ydoc) => {
  const contentSerializer = markdownSerializer(pmSchema)
  const newYdoc = new Doc()
  applyUpdateV2(newYdoc, fromBase64(ydoc))

  return contentSerializer.serialize(yDocToProsemirror(pmSchema, newYdoc))
}

global.toYDoc = toYDoc
global.fromYDoc = fromYDoc
