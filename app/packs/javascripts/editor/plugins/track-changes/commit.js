// @flow

import { Span, updateBlame } from './blame'
import { Step, Transform } from 'prosemirror-transform'

import { v4 as uuid } from 'uuid'

const hashString = (input: string) => {
  let hash = 0

  if (input.length === 0) {
    return btoa('0')
  }

  for (let i = 0; i < input.length; i++) {
    const charCode = input.charCodeAt(i)
    hash = (hash << 7) - hash + charCode
    hash = hash & hash
  }
  return btoa(hash.toString())
}

export const getCommitID = (changeIDs: string[]): string => {
  return `Commit:${hashString(
    changeIDs
      .slice()
      .sort()
      .join()
  )}`
}

export interface Commit {
  _id: string;
  changeID: string;
  blame: Span[];
  steps: Step[];
  prev: Commit | null;
  createdAt: number;
  updatedAt?: number;
}

export const smoosh = <T>(
  commit: Commit,
  selector: (commit: Commit) => T | Array<T>
): Array<T> => {
  const getFromSelector = () => {
    const result = selector(commit)
    return Array.isArray(result) ? result : [result]
  }
  if (commit.prev) {
    return smoosh(commit.prev, selector).concat(getFromSelector())
  }
  return getFromSelector()
}

export const buildCommit = (
  data: Omit<Commit, '_id' | 'updatedAt' | 'createdAt'>
): Commit => {
  const changeIDs = data.prev
    ? [data.changeID, ...smoosh(data.prev, (c) => c.changeID)]
    : [data.changeID]

  return {
    _id: getCommitID(changeIDs),
    updatedAt: Date.now() / 1000,
    createdAt: Date.now() / 1000,
    ...data
  }
}

export const emptyCommit = (): Commit => {
  return buildCommit({
    changeID: uuid(),
    blame: [],
    steps: [],
    prev: null
  })
}

export const freeze = (prev: Commit, tr?: Transform): Commit => {
  const changeID = uuid()

  return buildCommit({
    changeID,
    blame: tr ? updateBlame(prev.blame, tr.mapping, changeID) : prev.blame,
    steps: tr ? tr.steps : [],
    prev
  })
}

export const updateCommit = (commit: Commit, tr: Transform) => {
  const newBlame = updateBlame(commit.blame, tr.mapping, commit.changeID)

  return {
    ...commit,
    updatedAt: Date.now() / 1000,
    blame: newBlame,
    steps: commit.steps.concat(tr.steps)
  }
}
