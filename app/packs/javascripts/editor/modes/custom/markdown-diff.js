// CodeMirror, copyright (c) by Marijn Haverbeke and others
// Distributed under an MIT license: https://codemirror.net/LICENSE

import 'codemirror/mode/markdown/markdown'
import 'codemirror/mode/gfm/gfm'
import 'codemirror/mode/yaml/yaml'
import 'codemirror/mode/diff/diff'

import CodeMirror from 'codemirror'

var START = 0,
  FRONTMATTER = 1,
  DIFF = 2,
  BODY = 3

var INSERTION = /\+\w+/
var DELETION = /\-\w+/

CodeMirror.defineMode('markdown-diff', function(config, parserConfig) {
  var yamlMode = CodeMirror.getMode(config, 'yaml')
  var diffMode = CodeMirror.getMode(config, 'diff')
  var innerMode = CodeMirror.getMode(config, 'gfm')

  function localMode(state) {
    let mode

    switch (state.state) {
      case FRONTMATTER:
        break
        mode = { mode: yamlMode, state: state.yaml }
      case DIFF:
        break
        mode = { mode: diffMode, state: state.diff }
      default:
        mode = { mode: innerMode, state: state.inner }
        break
    }

    return mode
  }

  return {
    startState: function() {
      return {
        state: START,
        yaml: null,
        diff: null,
        inner: CodeMirror.startState(innerMode)
      }
    },
    copyState: function(state) {
      return {
        state: state.state,
        yaml: state.yaml && CodeMirror.copyState(yamlMode, state.yaml),
        diff: state.diff && CodeMirror.copyState(diffMode, state.diff),
        inner: CodeMirror.copyState(innerMode, state.inner)
      }
    },
    token: function(stream, state) {
      if (state.state == START) {
        if (stream.match(/(---|\.\.\.)/, false)) {
          state.state = FRONTMATTER
          state.yaml = CodeMirror.startState(yamlMode)
          return yamlMode.token(stream, state.yaml)
        } else {
          state.state = BODY
          return innerMode.token(stream, state.inner)
        }
      } else if (state.state == FRONTMATTER) {
        if (stream.match(INSERTION, false) || stream.match(DELETION, false)) {
          state.state = FRONTMATTER
          state.diff = CodeMirror.startState(diffMode)
          return diffMode.token(stream, state.diff)
        } else {
          var end = stream.match('---', false)
          var style = yamlMode.token(stream, state.yaml)

          if (end) {
            state.state = BODY
            state.yaml = null
          }

          return style
        }
      } else {
        if (stream.match(INSERTION, false) || stream.match(DELETION, false)) {
          state.state = DIFF
          state.diff = CodeMirror.startState(diffMode)
          return diffMode.token(stream, state.diff)
        } else {
          return innerMode.token(stream, state.inner)
        }
      }
    },
    innerMode: localMode,
    indent: function(state, a, b) {
      var m = localMode(state)
      return m.mode.indent ? m.mode.indent(m.state, a, b) : CodeMirror.Pass
    },
    blankLine: function(state) {
      var m = localMode(state)
      if (m.mode.blankLine) return m.mode.blankLine(m.state)
    }
  }
})
