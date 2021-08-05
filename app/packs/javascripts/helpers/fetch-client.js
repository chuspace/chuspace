// @flow

import 'whatwg-fetch'

import * as Rails from 'rails-ujs'

type ConfigObj = {
  headers: ?any,
  isConfigured: boolean
}

type Input = {
  url: string,
  body?: any,
  headers?: any,
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH'
}

export class FetchClient {
  isConfigured = false
  headers: any = {
    'Content-Type': 'application/json',
    'X-Requested-With': 'Chuspace fetch',
    'X-CSRF-TOKEN': Rails.csrfToken()
  }

  constructor() {
    if (typeof fetch === 'undefined') {
      // tslint:disable-next-line:max-line-length
      throw new Error(
        "FetchClient requires a Fetch API implementation, but the current environment doesn't support it. You may need to load a polyfill such as https://github.com/github/fetch"
      )
    }
  }

  fetch(input: Input): Promise<Response> {
    if (!input.method) {
      console.warn('No fetch method specified, using default GET method')
    }

    this.headers = Object.assign({}, this.headers, input.headers || {})
    this.isConfigured = true

    return fetch(input.url, {
      method: input.method || 'GET',
      body: JSON.stringify(input.body),
      credentials: 'same-origin',
      headers: this.headers
    })
  }

  get(input: Input): Promise<Response> {
    input.method = 'GET'
    return this.fetch(input)
  }

  post(input: Input): Promise<Response> {
    input.method = 'POST'
    return this.fetch(input)
  }

  put(input: Input): Promise<Response> {
    input.method = 'PUT'
    return this.fetch(input)
  }

  patch(input: Input): Promise<Response> {
    input.method = 'PATCH'
    return this.fetch(input)
  }

  delete(input: Input): Promise<Response> {
    input.method = 'DELETE'
    return this.fetch(input)
  }
}

export default new FetchClient()
