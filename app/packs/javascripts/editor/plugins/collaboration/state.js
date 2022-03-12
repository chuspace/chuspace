// @flow

import { Span } from './span'

function updateBlameMap(map, transform, clientIDs) {
  const result = []
  const mapping = transform.mapping
  for (let i = 0; i < map.length; i++) {
    const span = map[i]
    const from = mapping.map(span.from, 1)
    const to = mapping.map(span.to, -1)
    if (from < to) result.push(new Span(from, to, span.author))
  }

  for (let i = 0; i < mapping.maps.length; i++) {
    const map = mapping.maps[i]
    const after = mapping.slice(i + 1)
    map.forEach((_s, _e, start, end) => {
      insertIntoBlameMap(
        result,
        after.map(start, 1),
        after.map(end, -1),
        clientIDs[i]
      )
    })
  }

  return result
}

function insertIntoBlameMap(map, from, to, author) {
  if (from >= to) {
    return
  }
  let pos = 0
  let next
  for (; pos < map.length; pos++) {
    next = map[pos]
    if (next.author === author) {
      if (next.to >= from) break
    } else if (next.to > from) {
      // Different author, not before
      if (next.from < from) {
        // Sticks out to the left (loop below will handle right side)
        const left = new Span(next.from, from, next.author)
        if (next.to > to) map.splice(pos++, 0, left)
        else map[pos++] = left
      }
      break
    }
  }

  // eslint-ignore
  while ((next = map[pos])) {
    if (next.author === author) {
      if (next.from > to) break
      from = Math.min(from, next.from)
      to = Math.max(to, next.to)
      map.splice(pos, 1)
    } else {
      if (next.from >= to) break
      if (next.to > to) {
        map[pos] = new Span(to, next.to, next.author)
        break
      } else {
        map.splice(pos, 1)
      }
    }
  }

  map.splice(pos, 0, new Span(from, to, author))
}

export default class TrackState {
  constructor(blameMap) {
    this.blameMap = blameMap
  }

  applyTransform(transform) {
    const clientID =
      transform.getMeta('clientID') ?? transform.steps.map((item) => 'self')
    const newBlame = updateBlameMap(this.blameMap, transform, clientID)

    return new TrackState(newBlame)
  }
}
