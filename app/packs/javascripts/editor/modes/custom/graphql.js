// @flow

import { LexRules, ParseRules, isIgnored, onlineParser } from 'graphql-language-service-parser'

import CodeMirror from 'codemirror'

CodeMirror.defineMode('graphql', config => {
  const parser = onlineParser({
    eatWhitespace: stream => stream.eatWhile(isIgnored),
    lexRules: LexRules,
    parseRules: ParseRules,
    editorConfig: { tabSize: config.tabSize }
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
      explode: '()[]{}'
    }
  }
})

function indent(state, textAfter) {
  const levels = state.levels
  const level =
    !levels || levels.length === 0
      ? state.indentLevel
      : levels[levels.length - 1] - (this.electricInput.test(textAfter) ? 1 : 0)
  return level * this.config.indentUnit
}
