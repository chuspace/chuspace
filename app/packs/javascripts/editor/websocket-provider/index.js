// @flow

import * as Y from 'yjs'
import * as authProtocol from 'y-protocols/auth'
import * as awarenessProtocol from 'y-protocols/awareness'
import * as bc from 'lib0/broadcastchannel'
import * as decoding from 'lib0/decoding'
import * as encoding from 'lib0/encoding'
import * as math from 'lib0/math'
import * as mutex from 'lib0/mutex'
import * as syncProtocol from 'y-protocols/sync'
import * as time from 'lib0/time'
import * as url from 'lib0/url'

import ActioncableClient from 'helpers/actioncable-client'
import { Observable } from 'lib0/observable'

const messageSync = 0
const messageQueryAwareness = 3
const messageAwareness = 1
const messageAuth = 2

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

const reconnectTimeoutBase = 1200
const maxReconnectTimeout = 2500
// @todo - this should depend on awareness.outdatedTime
const messageReconnectTimeout = 30000

const permissionDeniedHandler = (provider, reason) =>
  console.warn(`Permission denied to access ${provider.url}.\n${reason}`)

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

const setupWS = (provider) => {
  if (provider.shouldConnect && provider.ws === null) {
    provider.wsconnecting = true
    provider.wsconnected = false
    provider.synced = false

    provider.ws = ActioncableClient.subscribe(
      {
        channel: provider.channel
      },
      {
        connected: () => {
          console.log('connected')
          provider.wsLastMessageReceived = time.getUnixTime()
          provider.wsconnecting = false
          provider.wsconnected = true

          provider.wsUnsuccessfulReconnects = 0
          provider.emit('status', [
            {
              status: 'connected'
            }
          ])
          // always send sync step 1 when connected
          const encoder = encoding.createEncoder()
          encoding.writeVarUint(encoder, messageSync)
          syncProtocol.writeSyncStep1(encoder, provider.doc)
          broadcastMessage(provider, encoding.toUint8Array(encoder))

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
            broadcastMessage(
              provider,
              encoding.toUint8Array(encoderAwarenessState)
            )
          }
        },

        disconnected: () => {
          console.log('disconnected')
          provider.ws = null
          provider.wsconnecting = false
          if (provider.wsconnected) {
            provider.wsconnected = false
            provider.synced = false
            // update awareness (all users except local left)
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
          } else {
            provider.wsUnsuccessfulReconnects++
          }
          // Start with no reconnect timeout and increase timeout by
          // log10(wsUnsuccessfulReconnects).
          // The idea is to increase reconnect timeout slowly and have no reconnect
          // timeout at the beginning (log(1) = 0)
          setTimeout(
            setupWS,
            math.min(
              math.log10(provider.wsUnsuccessfulReconnects + 1) *
                reconnectTimeoutBase,
              maxReconnectTimeout
            ),
            provider
          )
        },

        received: (response) => {
          console.log(new Uint8Array(response.data), 'recieved')
          provider.wsLastMessageReceived = time.getUnixTime()

          const encoder = readMessage(
            provider,
            new Uint8Array(response.data),
            true
          )

          if (encoding.length(encoder) > 1) {
            broadcastMessage(provider, encoding.toUint8Array(encoder))
          }

          console.log(provider._synced)
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

const broadcastMessage = (provider, buf) => {
  if (provider.wsconnected) {
    provider.ws.send({ data: [...buf] })
  }

  if (provider.bcconnected) {
    provider.mux(() => {
      bc.publish(provider.channel, buf)
    })
  }
}

export class WebsocketProvider extends Observable {
  constructor(
    channel,
    doc,
    {
      connect = true,
      awareness = new awarenessProtocol.Awareness(doc),
      params = {},
      resyncInterval = -1
    } = {}
  ) {
    super()

    this.channel = channel
    this.doc = doc
    this.params = params
    this.awareness = awareness

    this.wsconnected = false
    this.wsconnecting = false
    this.bcconnected = false
    this.wsUnsuccessfulReconnects = 0
    this.messageHandlers = messageHandlers.slice()
    this.mux = mutex.createMutex()
    this._synced = false
    this.ws = null
    this.wsLastMessageReceived = 0
    this.shouldConnect = connect

    this._resyncInterval = 0

    if (resyncInterval > 0) {
      this._resyncInterval = setInterval(() => {
        if (this.ws) {
          // resend sync step 1
          const encoder = encoding.createEncoder()
          encoding.writeVarUint(encoder, messageSync)
          syncProtocol.writeSyncStep1(encoder, doc)
          broadcastMessage(this, encoding.toUint8Array(encoder))
        }
      }, resyncInterval)
    }

    this._bcSubscriber = (data) => {
      this.mux(() => {
        const encoder = readMessage(this, new Uint8Array(data), false)
        if (encoding.length(encoder) > 1) {
          bc.publish(this.channel, encoding.toUint8Array(encoder))
        }
      })
    }

    this._updateHandler = (update, origin) => {
      if (origin !== this) {
        const encoder = encoding.createEncoder()
        encoding.writeVarUint(encoder, messageSync)
        syncProtocol.writeUpdate(encoder, update)

        broadcastMessage(this, encoding.toUint8Array(encoder))
      }
    }

    this.doc.on('update', this._updateHandler)

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

    this._checkInterval = setInterval(() => {
      if (
        this.wsconnected &&
        messageReconnectTimeout <
          time.getUnixTime() - this.wsLastMessageReceived
      ) {
        if (ActioncableClient.subscribedTo(this.channel)) {
          ActioncableClient.unsubscribe(this.channel)
        }
      }
    }, messageReconnectTimeout / 10)

    if (connect) {
      this.connect()
    }
  }

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

    clearInterval(this._checkInterval)

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
      bc.subscribe(this.channel, this._bcSubscriber)
      this.bcconnected = true
    }

    // send sync step1 to bc
    this.mux(() => {
      // write sync step 1
      const encoderSync = encoding.createEncoder()
      encoding.writeVarUint(encoderSync, messageSync)
      syncProtocol.writeSyncStep1(encoderSync, this.doc)
      bc.publish(this.channel, encoding.toUint8Array(encoderSync))
      // broadcast local state
      const encoderState = encoding.createEncoder()
      encoding.writeVarUint(encoderState, messageSync)
      syncProtocol.writeSyncStep2(encoderState, this.doc)
      bc.publish(this.channel, encoding.toUint8Array(encoderState))
      // write queryAwareness
      const encoderAwarenessQuery = encoding.createEncoder()
      encoding.writeVarUint(encoderAwarenessQuery, messageQueryAwareness)
      bc.publish(this.channel, encoding.toUint8Array(encoderAwarenessQuery))
      // broadcast local awareness state
      const encoderAwarenessState = encoding.createEncoder()
      encoding.writeVarUint(encoderAwarenessState, messageAwareness)
      encoding.writeVarUint8Array(
        encoderAwarenessState,
        awarenessProtocol.encodeAwarenessUpdate(this.awareness, [
          this.doc.clientID
        ])
      )
      bc.publish(this.channel, encoding.toUint8Array(encoderAwarenessState))
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
      bc.unsubscribe(this.channel, this._bcSubscriber)
      this.bcconnected = false
    }
  }

  disconnect() {
    this.shouldConnect = false
    this.disconnectBc()

    if (this.ws !== null) {
      if (ActioncableClient.subscribedTo(this.channel)) {
        ActioncableClient.unsubscribe(this.channel)
      }
    }
  }

  connect() {
    this.shouldConnect = true
    if (!this.wsconnected && this.ws === null) {
      setupWS(this)
      this.connectBc()
    }
  }
}
