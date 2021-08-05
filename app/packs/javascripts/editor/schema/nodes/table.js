// @flow

import {
  addColumnAfter,
  addColumnBefore,
  addRowAfter,
  addRowBefore,
  columnResizing,
  deleteColumn,
  deleteRow,
  deleteTable,
  fixTables,
  goToNextCell,
  mergeCells,
  setCellAttr,
  splitCell,
  tableEditing,
  toggleHeaderCell,
  toggleHeaderColumn,
  toggleHeaderRow
} from 'prosemirror-tables'
import { setBlockType, toggleBlockType } from 'editor/commands'

import { Node } from 'editor/base'
import { Node as PMNode } from 'prosemirror-model'
import TableNodes from './table-nodes'
import { createTable } from 'prosemirror-utils'
import { textblockTypeInputRule } from 'prosemirror-inputrules'

type Options = {
  levels: Array<number>
}

export default class Table extends Node {
  name = 'table'

  get defaultOptions() {
    return {
      resizable: false
    }
  }

  get schema() {
    return TableNodes.table
  }

  commands({ schema }) {
    return {
      createTable: ({ rowsCount, colsCount, withHeaderRow }) => (state, dispatch) => {
        const nodes = createTable(schema, rowsCount, colsCount, withHeaderRow)
        const tr = state.tr.replaceSelectionWith(nodes).scrollIntoView()
        dispatch(tr)
      },
      addColumnBefore: () => addColumnBefore,
      addColumnAfter: () => addColumnAfter,
      deleteColumn: () => deleteColumn,
      addRowBefore: () => addRowBefore,
      addRowAfter: () => addRowAfter,
      deleteRow: () => deleteRow,
      deleteTable: () => deleteTable,
      toggleCellMerge: () => (state, dispatch) => {
        if (mergeCells(state, dispatch)) {
          return
        }
        splitCell(state, dispatch)
      },
      mergeCells: () => mergeCells,
      splitCell: () => splitCell,
      toggleHeaderColumn: () => toggleHeaderColumn,
      toggleHeaderRow: () => toggleHeaderRow,
      toggleHeaderCell: () => toggleHeaderCell,
      setCellAttr: () => setCellAttr,
      fixTables: () => fixTables
    }
  }

  keys() {
    return {
      Tab: goToNextCell(1),
      'Shift-Tab': goToNextCell(-1)
    }
  }

  get plugins() {
    return [...(this.options.resizable ? [columnResizing()] : []), tableEditing()]
  }
}
