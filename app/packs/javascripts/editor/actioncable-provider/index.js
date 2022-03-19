/*
Unlike stated in the LICENSE file, it is not necessary to include the copyright notice and permission notice when you copy code from this file.
*/

/**
 * @module provider/actioncable
 */

/* eslint-env browser */

import * as Y from 'yjs' // eslint-disable-line
import * as authProtocol from 'y-protocols/auth'
import * as awarenessProtocol from 'y-protocols/awareness'
import * as bc from 'lib0/broadcastchannel'
import * as decoding from 'lib0/decoding'
import * as encoding from 'lib0/encoding'
import * as mutex from 'lib0/mutex'
import * as syncProtocol from 'y-protocols/sync'

import { fromBase64, toBase64 } from 'lib0/buffer'

import { Observable } from 'lib0/observable'

const messageSync = 0
const messageQueryAwareness = 3
const messageAwareness = 1
const messageAuth = 2

/**
 *                       encoder,          decoder,          provider,          emitSynced, messageType
 * @type {Array<function(encoding.Encoder, decoding.Decoder, ActionCableProvider, boolean,    number):void>}
 */
const messageHandlers = []

messageHandlers[messageSync] = (
  encoder,
  decoder,
  provider,
  emitSynced,
  messageType
) => {
  encoding.writeVarUint(encoder, messageSync)
  const syncMessageType = syncProtocol.readSyncMessage(
    decoder,
    encoder,
    provider.doc,
    provider
  )

  if (
    emitSynced &&
    syncMessageType === syncProtocol.messageYjsSyncStep2 &&
    !provider.synced
  ) {
    provider.synced = true
  }
}

messageHandlers[messageQueryAwareness] = (
  encoder,
  decoder,
  provider,
  emitSynced,
  messageType
) => {
  encoding.writeVarUint(encoder, messageAwareness)
  encoding.writeVarUint8Array(
    encoder,
    awarenessProtocol.encodeAwarenessUpdate(
      provider.awareness,
      Array.from(provider.awareness.getStates().keys())
    )
  )
}

messageHandlers[messageAwareness] = (
  encoder,
  decoder,
  provider,
  emitSynced,
  messageType
) => {
  awarenessProtocol.applyAwarenessUpdate(
    provider.awareness,
    decoding.readVarUint8Array(decoder),
    provider
  )
}

messageHandlers[messageAuth] = (
  encoder,
  decoder,
  provider,
  emitSynced,
  messageType
) => {
  authProtocol.readAuthMessage(decoder, provider.doc, permissionDeniedHandler)
}

/**
 * @param {ActionCableProvider} provider
 * @param {string} reason
 */
const permissionDeniedHandler = (provider, reason) =>
  console.warn(`Permission denied to access ${provider.url}.\n${reason}`)

/**
 * @param {ActionCableProvider} provider
 * @param {Uint8Array} buf
 * @param {boolean} emitSynced
 * @return {encoding.Encoder}
 */
const readMessage = (provider, buf, emitSynced) => {
  const decoder = decoding.createDecoder(buf)
  const encoder = encoding.createEncoder()
  const messageType = decoding.readVarUint(decoder)

  const messageHandler = provider.messageHandlers[messageType]

  if (messageHandler) {
    messageHandler(encoder, decoder, provider, emitSynced, messageType)
  } else {
    console.error('Unable to compute message')
  }
  return encoder
}

/**
 * @param {ActionCableProvider} provider
 */
const setupSubscription = (provider) => {
  if (provider.shouldConnect && provider.subscription === null) {
    provider.synced = false

    provider.subscription = provider.cable.subscriptions.create(
      provider.subscriptionParams,
      {
        received(data) {
          const encoder = readMessage(provider, fromBase64(data.message), true)

          if (encoding.length(encoder) > 1) {
            broadcastMessage(this, {
              message: toBase64(encoding.toUint8Array(encoder))
            })
          }
        },
        disconnected() {
          provider.synced = false
          awarenessProtocol.removeAwarenessStates(
            provider.awareness,
            Array.from(provider.awareness.getStates().keys()).filter(
              (client) => client !== provider.doc.clientID
            ),
            provider
          )
          provider.emit('status', [
            {
              status: 'disconnected'
            }
          ])
        },
        connected() {
          provider.emit('status', [
            {
              status: 'connected'
            }
          ])

          // always send sync step 1 when connected
          const encoder = encoding.createEncoder()
          encoding.writeVarUint(encoder, messageSync)
          syncProtocol.writeSyncStep1(encoder, provider.doc)
          broadcastMessage(this, {
            message: toBase64(encoding.toUint8Array(encoder))
          })
          // broadcast local awareness state
          if (provider.awareness.getLocalState() !== null) {
            const encoderAwarenessState = encoding.createEncoder()
            encoding.writeVarUint(encoderAwarenessState, messageAwareness)
            encoding.writeVarUint8Array(
              encoderAwarenessState,
              awarenessProtocol.encodeAwarenessUpdate(provider.awareness, [
                provider.doc.clientID
              ])
            )
            broadcastMessage(this, {
              message: toBase64(encoding.toUint8Array(encoderAwarenessState))
            })
          }
        }
      }
    )

    provider.emit('status', [
      {
        status: 'connecting'
      }
    ])
  }
}

/**
 * @param {ActionCableProvider} provider
 * @param {ArrayBuffer} buf
 */
const broadcastMessage = (provider, buf) => {
  if (provider.subscription) {
    provider.subscription.send({
      id: provider.subscriptionParams.id,
      message: toBase64(buf)
    })
  }

  if (provider.bcconnected) {
    provider.mux(() => {
      bc.publish(provider.bcChannel, buf)
    })
  }
}

/**
 * Action Cable Provider for Yjs. Creates an Action Cable subscription to sync the shared document.
 *
 * @example
 *   import * as Y from 'yjs'
 *   import { ActionCableProvider } from 'y-actioncable'
 *   import { createConsumer } from "@rails/actioncable"
 *   const doc = new Y.Doc()
 *   const provider = new ActionCableProvider(createConsumer(), { channel: 'my-channel', id: 1 }, doc)
 *
 * @extends {Observable<string>}
 */
export class ActionCableProvider extends Observable {
  /**
   * @param {ActionCable.Consumer} cable
   * @param {Object} subscriptionParams
   * @param {Y.Doc} doc
   * @param {object} [opts]
   * @param {boolean} [opts.connect]
   * @param {awarenessProtocol.Awareness} [opts.awareness]
   * @param {Object<string,string>} [opts.params]
   * @param {number} [opts.resyncInterval] Request server state every `resyncInterval` milliseconds
   */
  constructor(
    cable,
    subscriptionParams,
    doc,
    {
      connect = true,
      awareness = new awarenessProtocol.Awareness(doc),
      params = {},
      resyncInterval = -1
    } = {}
  ) {
    super()

    this.cable = cable

    this.subscriptionParams = subscriptionParams
    this.bcChannel = subscriptionParams.channel + '/' + subscriptionParams.id

    this.doc = doc
    this.awareness = awareness

    this.messageHandlers = messageHandlers.slice()
    this.mux = mutex.createMutex()
    /**
     * @type {boolean}
     */
    this._synced = false
    /**
     * @type {ActionCable.Subscription?}
     */
    this.subscription = null
    /**
     * Whether to connect to other peers or not
     * @type {boolean}
     */
    this.shouldConnect = connect

    /**
     * @type {number}
     */
    this._resyncInterval = 0
    if (resyncInterval > 0) {
      this._resyncInterval = /** @type {any} */ (setInterval(() => {
        if (this.subscription) {
          // resend sync step 1
          const encoder = encoding.createEncoder()
          encoding.writeVarUint(encoder, messageSync)
          syncProtocol.writeSyncStep1(encoder, doc)
          broadcastMessage(this, encoding.toUint8Array(encoder))
        }
      }, resyncInterval))
    }

    /**
     * @param {ArrayBuffer} data
     */
    this._bcSubscriber = (data) => {
      this.mux(() => {
        const encoder = readMessage(this, new Uint8Array(data), false)
        if (encoding.length(encoder) > 1) {
          bc.publish(this.bcChannel, encoding.toUint8Array(encoder))
        }
      })
    }

    /**
     * Listens to Yjs updates and sends them to remote peers (ActionCable and broadcastchannel)
     * @param {Uint8Array} update
     * @param {any} origin
     */
    this._updateHandler = (update, origin) => {
      if (origin !== this) {
        const encoder = encoding.createEncoder()
        encoding.writeVarUint(encoder, messageSync)
        syncProtocol.writeUpdate(encoder, update)
        broadcastMessage(this, encoding.toUint8Array(encoder))
      }
    }
    this.doc.on('update', this._updateHandler)
    /**
     * @param {any} changed
     * @param {any} origin
     */
    this._awarenessUpdateHandler = ({ added, updated, removed }, origin) => {
      const changedClients = added.concat(updated).concat(removed)
      const encoder = encoding.createEncoder()
      encoding.writeVarUint(encoder, messageAwareness)
      encoding.writeVarUint8Array(
        encoder,
        awarenessProtocol.encodeAwarenessUpdate(awareness, changedClients)
      )
      broadcastMessage(this, encoding.toUint8Array(encoder))
    }
    this._beforeUnloadHandler = () => {
      awarenessProtocol.removeAwarenessStates(
        this.awareness,
        [doc.clientID],
        'window unload'
      )
    }
    if (typeof window !== 'undefined') {
      window.addEventListener('beforeunload', this._beforeUnloadHandler)
    } else if (typeof process !== 'undefined') {
      process.on('exit', () => this._beforeUnloadHandler)
    }
    awareness.on('update', this._awarenessUpdateHandler)
    if (connect) {
      this.connect()
    }
  }

  /**
   * @type {boolean}
   */
  get synced() {
    return this._synced
  }

  set synced(state) {
    if (this._synced !== state) {
      this._synced = state
      this.emit('synced', [state])
      this.emit('sync', [state])
    }
  }

  destroy() {
    if (this._resyncInterval !== 0) {
      clearInterval(this._resyncInterval)
    }
    this.disconnect()
    if (typeof window !== 'undefined') {
      window.removeEventListener('beforeunload', this._beforeUnloadHandler)
    } else if (typeof process !== 'undefined') {
      process.off('exit', () => this._beforeUnloadHandler)
    }
    this.awareness.off('update', this._awarenessUpdateHandler)
    this.doc.off('update', this._updateHandler)
    super.destroy()
  }

  connectBc() {
    if (!this.bcconnected) {
      bc.subscribe(this.bcChannel, this._bcSubscriber)
      this.bcconnected = true
    }
    // send sync step1 to bc
    this.mux(() => {
      // write sync step 1
      const encoderSync = encoding.createEncoder()
      encoding.writeVarUint(encoderSync, messageSync)
      syncProtocol.writeSyncStep1(encoderSync, this.doc)
      bc.publish(this.bcChannel, encoding.toUint8Array(encoderSync))
      // broadcast local state
      const encoderState = encoding.createEncoder()
      encoding.writeVarUint(encoderState, messageSync)
      syncProtocol.writeSyncStep2(encoderState, this.doc)
      bc.publish(this.bcChannel, encoding.toUint8Array(encoderState))
      // write queryAwareness
      const encoderAwarenessQuery = encoding.createEncoder()
      encoding.writeVarUint(encoderAwarenessQuery, messageQueryAwareness)
      bc.publish(this.bcChannel, encoding.toUint8Array(encoderAwarenessQuery))
      // broadcast local awareness state
      const encoderAwarenessState = encoding.createEncoder()
      encoding.writeVarUint(encoderAwarenessState, messageAwareness)
      encoding.writeVarUint8Array(
        encoderAwarenessState,
        awarenessProtocol.encodeAwarenessUpdate(this.awareness, [
          this.doc.clientID
        ])
      )
      bc.publish(this.bcChannel, encoding.toUint8Array(encoderAwarenessState))
    })
  }

  disconnectBc() {
    // broadcast message with local awareness state set to null (indicating disconnect)
    const encoder = encoding.createEncoder()
    encoding.writeVarUint(encoder, messageAwareness)
    encoding.writeVarUint8Array(
      encoder,
      awarenessProtocol.encodeAwarenessUpdate(
        this.awareness,
        [this.doc.clientID],
        new Map()
      )
    )
    broadcastMessage(this, encoding.toUint8Array(encoder))
    if (this.bcconnected) {
      bc.unsubscribe(this.bcChannel, this._bcSubscriber)
      this.bcconnected = false
    }
  }

  disconnect() {
    this.shouldConnect = false
    this.disconnectBc()
    if (this.subscription !== null) {
      this.subscription.unsubscribe()
    }
  }

  connect() {
    this.shouldConnect = true
    if (this.subscription === null) {
      setupSubscription(this)
      this.connectBc()
    }
  }
}
