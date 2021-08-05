// @flow

import { Node } from 'editor/base'
import TableNodes from './table-nodes'

export default class TableHeader extends Node {
  name = 'table_header'

  get schema() {
    return TableNodes.table_header
  }
}
