// @flow

export default class Item {
  id: number
  action: 'add' | 'remove'
  type: 'add' | 'delete' | 'format'

  constructor(action: 'add' | 'remove', type: 'add' | 'delete' | 'format') {
    this.id = Math.floor(Math.random() * 0xffffffff)
    this.action = action
    this.type = type
  }
}
