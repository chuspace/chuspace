import { createConsumer, logger } from '@rails/actioncable'

logger.enabled = true
class ActionCableClient {
  static instance

  consumer = null
  subscriptions = new Map()

  constructor() {
    if (ActionCableClient.instance) return ActionCableClient.instance

    this.consumer = createConsumer()
    ActionCableClient.instance = this
  }

  reconnect = () => (this.consumer = createConsumer())

  subscribe = (opts, handlers) => {
    const subscription = this.consumer.subscriptions.create(opts, handlers)

    this.subscriptions = this.subscriptions.set(opts.channel, subscription)

    return subscription
  }

  subscribedTo = (channel) => this.subscriptions.has(channel)

  unsubscribe = (channel) => {
    const subscription = this.subscriptions.get(channel)
    this.subscriptions.delete(channel)
    this.consumer.subscriptions.remove(subscription)
  }

  unsubscribeAll = () => {
    this.subscriptions.forEach((_, channel) => this.unsubscribe(channel))

    this.subscriptions = this.subscriptions.clear()
  }
}

export default new ActionCableClient()
