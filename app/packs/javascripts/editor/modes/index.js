// @flow

import type { LanguageType } from './modes'
import { MODES } from './modes'
import toHash from 'tohash'

export const DEFAULT_MODE: string = 'auto'

export const loadMode = async (mode: string) => {
  const language: ?LanguageType = MODES.filter(
    language => language.mode && language.mode !== 'auto' && language.mode !== 'text' && language.mode !== 'javascript'
  ).find((language: LanguageType) => language.mode === mode)

  if (language) {
    language.custom
      ? /* $FlowFixMe */
        await import(`./custom/${language.mode}`)
      : /* $FlowFixMe */
        await import(`codemirror/mode/${language.mode}/${language.mode}`)
  }

  return language
}

const LANGUAGE_MIME_HASH = toHash(MODES, 'mime')
const LANGUAGE_MODE_HASH = toHash(MODES, 'mode')
const LANGUAGE_NAME_HASH = toHash(MODES, 'short')

export { MODES, LANGUAGE_MIME_HASH, LANGUAGE_MODE_HASH, LANGUAGE_NAME_HASH }
