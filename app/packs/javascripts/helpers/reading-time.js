// @flow

function ansiWordBound(c: string) {
  return ' ' === c || '\n' === c || '\r' === c || '\t' === c
}

const WORDS_PER_MINUTE = 200

export default function readingTime(text: string) {
  let words = 0
  let start = 0
  let end = text.length - 1
  let i

  while (ansiWordBound(text[start])) start++
  while (ansiWordBound(text[end])) end--

  for (i = start; i <= end; ) {
    for (; i <= end && !ansiWordBound(text[i]); i++);
    words++
    for (; i <= end && ansiWordBound(text[i]); i++);
  }

  const minutes: number = words / WORDS_PER_MINUTE
  const time: number = minutes * 60 * 1000
  const displayed = Math.ceil(parseFloat(minutes.toFixed(2)))

  return {
    text: displayed + ' min read',
    minutes: minutes,
    time: time,
    words: words
  }
}
