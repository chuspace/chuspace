// @flow

import './styles.sass'
import './themes/light.sass'
import './themes/dark.sass'
import 'tippy.js/dist/tippy.css'

import { LitElement, css, html, svg } from 'lit'

import ClipboardJS from 'clipboard'
import CodeMirror from 'editor/codemirror'
import Controls from './controls'
import { CopyClipboard } from 'editor/components'
import { EditorView } from 'prosemirror-view'
import tippy from 'tippy.js'

export default class CodeEditor extends LitElement {
  cm: ?CodeMirror

  static properties = {
    mode: { type: String, reflect: true },
    readonly: { type: Boolean },
    wrapper: { type: Boolean },
    theme: { type: String },
    filename: { type: String },
    contribution: { type: Boolean },
    downloadable: { type: String },
    onChange: { type: Function },
    content: { type: String, reflect: true },
    onInit: { type: Function },
    codeMirrorKeymap: { type: Function },
    onLanguageChange: { type: Function },
    onDestroy: { type: Function },
  }

  constructor() {
    super()

    this.theme = window.colorScheme
    this.downloadable = true
    this.lines = 0
  }

  onLanguageChange = async (event: Event, update: boolean = false) => {
    const modeObj = CodeMirror.lookupMode(event.target.value)

    if (modeObj) {
      this.setMode(modeObj.mode)
      this.onLanguageChange(event.target.value)
    }
  }

  setMode = async (mode: String) => {
    if (mode) {
      this.cm.setOption('mode', mode)
      await CodeMirror.autoLoadMode(this.cm, mode)
    }
  }

  attachObserver = () => {
    this.observer = new IntersectionObserver(this.handleIntersection.bind(this), {
      root: null,
      rootMargin: '0px',
      threshold: [0, 0.25, 0.5, 0.75, 1],
    })

    this.observer.observe(this)
  }

  handleIntersection = (entries: Array<any>, observer) => {
    entries.forEach(({ intersectionRatio }) => {
      if (intersectionRatio > 0.1) {
        this.loadEditor()
        observer.unobserve(this)
      }
    })
  }

  loadEditor = () => {
    if (this.cm) return

    this.cm = this.createCM(this.renderRoot.querySelector('textarea'))
    if (this.onInit) this.onInit(this.cm)

    this.setMode(CodeMirror.lookupMode(this.mode)?.mode)

    this.cm.on('change', (editor) => {
      if (this.onChange) this.onChange(editor.doc.getValue())
    })
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
    CodeMirror.fromTextArea(node, {
      lineNumbers: true,
      styleActiveLine: true,
      smartIndent: !this.readonly,
      readOnly: this.readonly || false,
      indentUnit: 2,
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

  createRenderRoot() {
    return this
  }

  renderSwitcher() {
    return html`
      <div class="code-editor-language-switcher-container mr-4">
        <div class="dropdown dropdown-end">
          <input
            type="text"
            placeholder="Type to search..."
            value=${this.mode}
            @change=${this.onLanguageChange}
            class="input input-sm w-full max-w-xs"
          />
        </div>
      </div>
    `
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
                    ? this.mode
                      ? html`<div class="code-editor-language-badge badge badge-primary mr-4">${this.mode}</div> `
                      : null
                    : this.renderSwitcher()}

                  <copy-clipboard class="link link-primary" .initClipboardJS=${this.initClipboardJS}></copy-clipboard>
                </div>
              </div>
            `
          : null}

        <textarea
          rows="${this.lines}"
          class="textarea textarea-md bg-transparent w-full"
          .value=${this.content.trim()}
        ></textarea>
      </div>
    `
  }
}

document.addEventListener('turbo:load', () => {
  if (!window.customElements.get('code-editor')) {
    customElements.define('code-editor', CodeEditor)
  }
})
