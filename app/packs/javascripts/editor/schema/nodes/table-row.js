// @flow

import { Node } from 'editor/base'
import TableNodes from './table-nodes'

export default class TableRow extends Node {
  name = 'table_row'

  get schema() {
    return TableNodes.table_cell
  }
}
