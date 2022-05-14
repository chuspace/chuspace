// @flow

import 'codemirror-mode-elixir'
import 'codemirror/addon/fold/foldgutter.css'
import 'codemirror/mode/javascript/javascript'
import 'codemirror/mode/meta'
import 'codemirror/addon/edit/matchbrackets'
import 'codemirror/addon/edit/closebrackets'
import 'codemirror/addon/edit/matchtags'
import 'codemirror/addon/edit/trailingspace'
import 'codemirror/addon/edit/closetag'
import 'codemirror/addon/fold/foldcode'
import 'codemirror/addon/fold/foldgutter'
import 'codemirror/addon/fold/indent-fold'
import 'codemirror/addon/fold/brace-fold'
import 'codemirror/addon/fold/comment-fold'
import 'codemirror/addon/fold/markdown-fold'
import 'codemirror/addon/display/autorefresh'
import 'codemirror/addon/mode/multiplex'
import 'codemirror/lib/codemirror.css'

import * as CodeMirror from 'codemirror'

import { LexRules, ParseRules, isIgnored, onlineParser } from 'graphql-language-service-parser'

// Make CodeMirror available globally so the modes' can register themselves.
window.CodeMirror = CodeMirror

if (!CodeMirror.modeURL) CodeMirror.modeURL = 'codemirror/mode/%N/%N.js'

var loading = {}

function splitCallback(cont, n) {
  var countDown = n
  return function () {
    if (--countDown === 0) cont()
  }
}

function ensureDeps(mode, cont) {
  var deps = CodeMirror.modes[mode].dependencies
  if (!deps) return cont()
  var missing = []
  for (var i = 0; i < deps.length; ++i) {
    if (!CodeMirror.modes.hasOwnProperty(deps[i])) missing.push(deps[i])
  }
  if (!missing.length) return cont()
  var split = splitCallback(cont, missing.length)
  for (i = 0; i < missing.length; ++i) CodeMirror.requireMode(missing[i], split)
}

CodeMirror.autoLoadMode = function (instance, mode) {
  if (CodeMirror.modes.hasOwnProperty(mode)) return

  import(`codemirror/mode/${mode}/${mode}`).then(() => instance.setOption('mode', instance.getOption('mode')))
}

CodeMirror.defineMode('apache', (/* config */) => {
  return {
    token: (stream, state) => {
      var sol = stream.sol() || state.afterSection
      var eol = stream.eol()

      state.afterSection = false

      if (sol) {
        if (state.nextMultiline) {
          state.inMultiline = true
          state.nextMultiline = false
        } else {
          state.position = 'def'
        }
      }

      if (eol && !state.nextMultiline) {
        state.inMultiline = false
        state.position = 'def'
      }

      if (sol) {
        while (stream.eatSpace()) {
          /* pass */
        }
      }

      var ch = stream.next()

      if (sol && ch === '#') {
        state.position = 'comment'
        stream.skipToEnd()
        return 'comment'
      } else if (ch === '!' && stream.peek() !== ' ') {
        return 'number'
      } else if (ch === ' ') {
        if (stream.peek() === '[') {
          if (stream.skipTo(']')) {
            stream.next()
          } else {
            stream.skipToEnd()
          }
          return 'keyword'
        } else if (stream.peek() === '(') {
          if (stream.skipTo(')')) {
            stream.next()
          } else {
            stream.skipToEnd()
          }
          return 'string'
        } else {
          state.position = 'unit'
          return 'unit'
        }
      } else if (ch === '"') {
        if (stream.skipTo('"')) {
          stream.next()
        } else {
          stream.skipToEnd()
        }
        return 'quote'
      } else if (sol && ch === '<') {
        if (stream.skipTo('>')) {
          stream.next()
        } else {
          stream.skipToEnd()
        }
        return 'meta'
      } else if (ch === '%') {
        if (stream.peek() === '{') {
          if (stream.skipTo('}')) {
            stream.next()
          } else {
            stream.skipToEnd()
          }
          return 'operator'
        }
      } else if (ch === '$') {
        if (!isNaN(stream.peek()) && stream.peek() !== ' ') {
          while (!isNaN(stream.peek()) && stream.peek() !== ' ') {
            stream.next()
          }
          return 'operator'
        }
      } else if (ch === '\\') {
        if (stream.peek() === '.') {
          if (stream.skipTo(' ')) {
            stream.next()
          } else {
            stream.skipToEnd()
          }
          return 'string'
        }
      } else if (ch === '.') {
        if (stream.peek() === '*') {
          if (stream.skipTo(' ')) {
            stream.next()
          } else {
            stream.skipToEnd()
          }
          return 'string'
        }
      } else if (ch === '^') {
        if (stream.skipTo(' ')) {
          stream.next()
        } else {
          stream.skipToEnd()
        }
        return 'string'
      }

      return state.position
    },

    // electricInput: /<\/[\s\w:]+>$/,
    lineComment: '#',
    fold: 'brace',

    startState: () => {
      return {
        position: 'def',
        nextMultiline: false,
        inMultiline: false,
        afterSection: false,
      }
    },
  }
})

CodeMirror.defineMode('graphql', (config) => {
  const parser = onlineParser({
    eatWhitespace: (stream) => stream.eatWhile(isIgnored),
    lexRules: LexRules,
    parseRules: ParseRules,
    editorConfig: { tabSize: config.tabSize },
  })

  return {
    config,
    startState: parser.startState,
    token: parser.token,
    indent,
    electricInput: /^\s*[})\]]/,
    fold: 'brace',
    lineComment: '#',
    closeBrackets: {
      pairs: '()[]{}""',
      explode: '()[]{}',
    },
  }
})

CodeMirror.defineMIME('text/apache', 'apache')
CodeMirror.defineMIME('text/htaccess', 'apache')

export default CodeMirror
