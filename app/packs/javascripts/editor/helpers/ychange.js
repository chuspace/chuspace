// @flow

export const calcYChangeStyle = (ychange) => {
  switch (ychange.type) {
    case 'removed':
      return `color:${ychange.color.dark}`
    case 'added':
      return `border-color:${ychange.color.light}`
    case null:
      return ''
  }
}

export const calcYchangeDomAttrs = (attrs, domAttrs = {}) => {
  domAttrs = Object.assign({}, domAttrs)
  if (attrs.ychange !== null) {
    domAttrs.ychange_user = attrs.ychange.user
    domAttrs.ychange_type = attrs.ychange.type
    domAttrs.ychange_color = attrs.ychange.color.light
  }
  return domAttrs
}

export const hoverWrapper = (ychange, els) =>
  ychange === null
    ? els
    : [
        [
          'span',
          {
            class: 'ychange-hover',
            style: `background-color:${ychange.color.dark}`
          },
          ychange.user || 'Unknown'
        ],
        ['span', ...els]
      ]
