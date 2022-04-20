// @flow

import { Plugin, PluginKey } from 'prosemirror-state'

class Span {
  constructor(from, to, commit) {
    this.from = from
    this.to = to
    this.commit = commit
  }
}

class Commit {
  constructor(message, time, steps, maps, hidden) {
    this.message = message
    this.time = time
    this.steps = steps
    this.maps = maps
    this.hidden = hidden
  }
}

class TrackState {
  constructor(commits, uncommittedSteps, uncommittedMaps) {
    this.commits = commits
    this.uncommittedSteps = uncommittedSteps
    this.uncommittedMaps = uncommittedMaps
  }

  applyTransform(transform) {
    const inverted = transform.steps.map((step, i) =>
      step.invert(transform.docs[i]).toJSON()
    )

    return new TrackState(
      this.commits,
      this.uncommittedSteps.concat(inverted),
      this.uncommittedMaps.concat(transform.mapping.maps)
    )
  }

  applyCommit(message) {
    if (this.uncommittedSteps.length == 0) return this

    const commit = new Commit(
      message,
      new Date().getTime(),
      this.uncommittedSteps,
      this.uncommittedMaps
    )

    return new TrackState(this.commits.concat(commit), [], [])
  }
}

export const trackPluginName = 'track-change'
export const trackPluginKey = new PluginKey(trackPluginName)

export const trackPlugin = new Plugin({
  key: trackPluginKey,
  state: {
    init(config, state) {
      return new TrackState(
        config.commits.length > 0
          ? config.commits
          : [new Span(0, state.doc.content.size, null)],
        [],
        [],
        []
      )
    },
    apply(tr, tracked) {
      if (tr.docChanged) tracked = tracked.applyTransform(tr)
      const commitMessage = tr.getMeta(this)

      if (commitMessage)
        tracked = tracked.applyCommit(commitMessage, new Date(tr.time))
      return tracked
    }
  }
})
