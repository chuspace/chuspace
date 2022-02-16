// @flow

import 'codemirror/lib/codemirror.css'
import './styles.sass'
import './themes/light.sass'
import './themes/dark.sass'
import 'codemirror/addon/fold/foldgutter.css'
import 'codemirror/mode/javascript/javascript'
import 'codemirror/addon/edit/matchbrackets'
import 'codemirror/addon/edit/closebrackets'
import 'codemirror/addon/edit/matchtags'
import 'codemirror/addon/edit/trailingspace'
import 'codemirror/addon/edit/closetag'
import 'codemirror/addon/fold/foldcode'
import 'codemirror/addon/fold/foldgutter'
import 'codemirror/addon/fold/indent-fold'
import 'codemirror/addon/fold/brace-fold'
import 'codemirror/addon/fold/comment-fold'
import 'codemirror/addon/fold/markdown-fold'
import 'codemirror/addon/display/autorefresh'
import './language-switcher'

import * as CodeMirror from 'codemirror'

import { LitElement, css, html, svg } from 'lit'
import { MODES, loadMode } from 'editor/modes'

import ClipboardJS from 'clipboard'
import Controls from './controls'
import { CopyClipboard } from 'editor/components'
import { EditorView } from 'prosemirror-view'
import tippy from 'tippy.js'

export default class CodeEditor extends LitElement {
  cm: ?CodeMirror

  static properties = {
    mode: { type: String, reflect: true },
    readonly: { type: String },
    lazy: { type: String },
    wrapper: { type: String },
    theme: { type: String },
    loaded: { type: Boolean },
    content: { type: String, reflect: true },
    onInit: { type: Function },
    codeMirrorKeymap: { type: Function },
    onLanguageChange: { type: Function },
    onDestroy: { type: Function }
  }

  constructor() {
    super()

    this.theme = window.colorScheme
    this.loaded = false
    this.wrapper = true
    this.lazy = true
    this.lines = 0

    this.options = {
      root: null,
      rootMargin: '0px',
      threshold: [0, 0.25, 0.5, 0.75, 1]
    }
  }

  setMode = async (mode: string) => {
    await loadMode(mode)

    this.mode = mode
    this.onLanguageChange(mode)
  }

  attachObserver = () => {
    if (this.observer) {
      this.removeObserver()
    }

    this.observer = new IntersectionObserver(
      this.handleIntersection.bind(this),
      this.options
    )
    this.observer.observe(this)
  }

  removeObserver = () => {
    this.observer.unobserve(this)
    this.observer = null
  }

  handleIntersection(entries: Array<any>) {
    entries.forEach(({ intersectionRatio }) => {
      if (intersectionRatio === 0) {
        if (this.timer) {
          clearTimeout(this.timer)
          this.timer = null
        }
      } else if (intersectionRatio > 0.1) {
        this.timer = setTimeout(() => this.loadEditor(), this.delay)
      }
    })
  }

  loadEditor = async () => {
    if (this.cm) return
    const codeNode = this.querySelector('.code-editor')
    await loadMode(this.mode)
    this.cm = await this.createCM(codeNode)
    if (this.onInit) await this.onInit(this.cm)

    this.loaded = true

    if (this.lazy) this.removeObserver()
  }

  async connectedCallback() {
    await super.connectedCallback()
    this.lines = this.content.split(/\r\n|\r|\n/).length

    try {
      this.readonly = JSON.parse(this.readonly)
      this.wrapper = JSON.parse(this.wrapper)
      this.lazy = JSON.parse(this.lazy)
    } catch (e) {}

    if (this.lazy) {
      this.attachObserver()
    } else {
      await this.loadEditor()
    }
  }

  createRenderRoot() {
    return this
  }

  createCM = async (node: ?HTMLElement) =>
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
      gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter'],
      indentWithTabs: !this.readonly,
      theme: `chuspace-${this.theme}`,
      addModeClass: true,
      extraKeys: this.codeMirrorKeymap && this.codeMirrorKeymap(),
      autoCloseBrackets: !this.readonly,
      autoCloseTags: !this.readonly,
      showTrailingSpace: !this.readonly,
      matchTags: !this.readonly
    })

  initClipboardJS = (node: ?HTMLElement) => {
    const clipboard = new ClipboardJS(node, {
      text: (trigger) => this.cm && this.cm.getDoc().getValue()
    })

    clipboard.on('success', (e) => {
      this.cm && this.cm.execCommand('selectAll')
      const instance = tippy(node, {
        arrow: true,
        showOnCreate: true,
        trigger: 'click',
        content: 'Copied'
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
          : 'no-wrapper'} font-sans code-editor-container--${this.theme}"
        contenteditable="false"
      >
        ${this.wrapper
          ? html`
              <div class="code-editor-toolbar" contenteditable="false">
                ${this.readonly ? null : Controls({ destroy: this.onDestroy })}
                ${this.readonly
                  ? svg`
            <svg class='fill-current' xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24"><path d="M4.97 11.03a.75.75 0 111.06-1.06L11 14.94V2.75a.75.75 0 011.5 0v12.19l4.97-4.97a.75.75 0 111.06 1.06l-6.25 6.25a.75.75 0 01-1.06 0l-6.25-6.25zm-.22 9.47a.75.75 0 000 1.5h14.5a.75.75 0 000-1.5H4.75z"></path></svg>
            `
                  : null}
                <div class="code-editor-toolbar-menu" contenteditable="false">
                  ${this.readonly
                    ? html`
                        <div
                          class="code-editor-language-badge badge badge-primary mr-4"
                        >
                          ${this.mode}
                        </div>
                      `
                    : html`
                        <code-editor-language-switcher
                          mode=${this.mode}
                          readonly=${this.readonly}
                          .setMode=${this.setMode}
                        ></code-editor-language-switcher>
                      `}

                  <copy-clipboard
                    .initClipboardJS=${this.initClipboardJS}
                  ></copy-clipboard>
                </div>
              </div>
            `
          : null}

        <div class="code-editor">
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
