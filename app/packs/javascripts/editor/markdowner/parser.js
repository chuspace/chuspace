// @flow

import { MarkdownParser } from 'prosemirror-markdown'
import { Schema } from 'prosemirror-model'
import frontMatterPlugin from './front-matter-plugin'
import markdownit from 'markdown-it'
import queryString from 'query-string'

const parsableNodes = {
  blockquote: { block: 'blockquote' },
  paragraph: { block: 'paragraph' },
  list_item: { block: 'list_item' },
  bullet_list: { block: 'bullet_list' },
  ordered_list: {
    block: 'ordered_list',
    getAttrs: (tok) => ({ order: +tok.attrGet('order') || 1 })
  },
  front_matter: {
    block: 'front_matter',
    noCloseToken: true
  },
  heading: {
    block: 'heading',
    getAttrs: (tok) => ({ level: +tok.tag.slice(1) })
  },
  code_block: {
    block: 'code_block',
    getAttrs: (tok: any) => {
      return {
        language: (tok.info && tok.info.trim()) || null
      }
    }
  },
  fence: {
    block: 'code_block',
    getAttrs: (tok) => ({ language: (tok.info && tok.info.trim()) || null })
  },
  hr: { node: 'horizontal_rule' },
  image: {
    node: 'image',
    getAttrs: (tok) => {
      return {
        src: tok.attrGet('src'),
        title: tok.attrGet('title') || null,
        alt: (tok.children[0] && tok.children[0].content) || null
      }
    }
  },
  hardbreak: { node: 'hard_break' }
}

export default (schema: Schema) => {
  const schemaNodes = [...Object.keys(schema.nodes), 'fence']
    .filter((node) => Object.keys(parsableNodes).includes(node) || node.name)
    .reduce(
      (nodes, name) => ({
        ...nodes,
        [name]: parsableNodes[name]
      }),
      {}
    )

  return new MarkdownParser(
    schema,
    markdownit('commonmark', {
      html: false
    }).use(frontMatterPlugin),
    {
      ...schemaNodes,
      em: { mark: 'em' },
      strong: { mark: 'strong' },
      link: {
        mark: 'link',
        getAttrs: (tok) => ({
          href: tok.attrGet('href'),
          title: tok.attrGet('title') || null
        })
      },
      code_inline: { mark: 'code' }
    }
  )
}
