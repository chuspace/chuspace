// @flow

import './styles.sass'
import './themes/light.sass'
import './themes/dark.sass'
import 'tippy.js/dist/tippy.css'
import './language-switcher'

import { LitElement, css, html, svg } from 'lit'

import ClipboardJS from 'clipboard'
import CodeMirror from 'editor/codemirror'
import Controls from './controls'
import { CopyClipboard } from 'editor/components'
import { EditorView } from 'prosemirror-view'
import { query } from 'lit/decorators/query.js'
import tippy from 'tippy.js'

export default class CodeEditor extends LitElement {
  cm: ?CodeMirror
  @query('.code-editor')
  _codeEditor

  static properties = {
    mode: { type: String, reflect: true },
    readonly: { type: Boolean },
    wrapper: { type: Boolean },
    theme: { type: String },
    filename: { type: String },
    contribution: { type: Boolean },
    downloadable: { type: String },
    onChange: { type: Function },
    loaded: { type: Boolean },
    content: { type: String, reflect: true },
    onInit: { type: Function },
    codeMirrorKeymap: { type: Function },
    onLanguageChange: { type: Function },
    onDestroy: { type: Function },
  }

  constructor() {
    super()

    this.theme = window.colorScheme
    this.loaded = false
    this.downloadable = true
    this.lines = 0
  }

  setMode = async (mode: string) => {
    this.mode = mode
    this.cm.setOption('mode', mode)
    await CodeMirror.autoLoadMode(this.cm, mode)
    this.onLanguageChange(mode)
  }

  attachObserver = () => {
    this.observer = new IntersectionObserver(this.handleIntersection.bind(this), {
      root: null,
      rootMargin: '0px',
      threshold: [0, 0.25, 0.5, 0.75, 1],
    })

    this.observer.observe(this)
  }

  handleIntersection(entries: Array<any>, observer) {
    entries.forEach(({ intersectionRatio }) => {
      if (intersectionRatio > 0.1) {
        this.loadEditor()
        observer.unobserve(this)
      }
    })
  }

  get codeEditorNode() {
    return this.renderRoot.querySelector('#code-editor')
  }

  loadEditor = () => {
    if (this.cm || this.loaded) return

    let mode = this.mode
    const regex = /[a-zA-Z]+/g

    if (this.mode) {
      const matches = this.mode.match(regex)

      if (matches) {
        mode =
          CodeMirror.findModeByMIME(matches[0]) ||
          CodeMirror.findModeByExtension(matches[0]) ||
          CodeMirror.findModeByFileName(matches[0]) ||
          CodeMirror.findModeByName(matches[0])
      }
    }

    this.mode = mode.mode

    this.cm = this.createCM(this.codeEditorNode)
    if (this.onInit) this.onInit(this.cm)

    this.cm.on('change', (editor) => {
      if (this.onChange) this.onChange(editor.doc.getValue())
    })

    CodeMirror.autoLoadMode(this.cm, this.mode)

    this.loaded = true
  }

  connectedCallback() {
    super.connectedCallback()
    this.lines = this.content.split(/\r\n|\r|\n/).length
    this.attachObserver()
  }

  createRenderRoot() {
    return this
  }

  createCM = (node: ?HTMLElement) =>
    new CodeMirror(node, {
      lineNumbers: true,
      styleActiveLine: true,
      smartIndent: !this.readonly,
      readOnly: this.readonly || false,
      indentUnit: 2,
      value: this.content.trim(),
      mode: this.mode,
      lineWrapping: true,
      foldGutter: true,
      scrollbarStyle: 'null',
      gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter'],
      indentWithTabs: !this.readonly,
      theme: `chuspace-${this.theme}`,
      addModeClass: true,
      extraKeys: this.codeMirrorKeymap && this.codeMirrorKeymap(),
      autoCloseBrackets: !this.readonly,
      autoCloseTags: !this.readonly,
      showTrailingSpace: !this.readonly,
      matchTags: !this.readonly,
    })

  initClipboardJS = (node: ?HTMLElement) => {
    const clipboard = new ClipboardJS(node, {
      text: (trigger) => this.cm && this.cm.getDoc().getValue(),
    })

    clipboard.on('success', (e) => {
      this.cm && this.cm.execCommand('selectAll')
      const instance = tippy(node, {
        arrow: true,
        showOnCreate: true,
        trigger: 'click',
        content: 'Copied',
      })

      setTimeout(() => {
        this.cm && this.cm.execCommand('undoSelection')
        instance.destroy()
      }, 1000)
    })
  }

  render = () => {
    return html`
      <div
        class="code-editor-container ${this.wrapper
          ? 'has-wrapper'
          : 'no-wrapper'} font-sans code-editor-container--${this.theme}
          ${this.contribution ? 'contribution-modal' : 'editor'}"
        contenteditable="false"
      >
        ${this.wrapper
          ? html`
              <div class="code-editor-toolbar" contenteditable="false">
                ${!this.readonly ? Controls({ destroy: this.onDestroy }) : null}
                ${this.filename ? html` <span>${this.filename}</span> ` : null}

                <div class="code-editor-toolbar-menu" contenteditable="false">
                  ${this.readonly
                    ? html` <div class="code-editor-language-badge badge badge-primary mr-4">${this.mode}</div> `
                    : html`
                        <code-editor-language-switcher
                          mode=${this.mode}
                          readonly=${this.readonly}
                          .setMode=${this.setMode}
                        ></code-editor-language-switcher>
                      `}

                  <copy-clipboard .initClipboardJS=${this.initClipboardJS}></copy-clipboard>
                </div>
              </div>
            `
          : null}

        <div class="code-editor" id="code-editor">
          ${!this.loaded
            ? html`
                <content-loader
                  contentEditable="false"
                  lines=${this.lines}
                  class="block whitespace-no-wrap py-4"
                ></content-loader>
              `
            : null}
        </div>
      </div>
    `
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('code-editor')) {
    customElements.define('code-editor', CodeEditor)
  }
})
