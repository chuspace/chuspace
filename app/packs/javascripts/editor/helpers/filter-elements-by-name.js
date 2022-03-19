// @flow

const filterElementsBy = (elements: [], type: string) => {
  return elements
    .filter((element) => element.type === type)
    .reduce(
      (nodes, { name, schema }) => ({
        ...nodes,
        [name]: schema
      }),
      {}
    )
}

export default filterElementsBy
