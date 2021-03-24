# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'citext'

    create_table :users do |t|
      t.string :name
      t.citext :username
      t.string :uid, index: true
      t.string :provider, index: true
      t.text :token
      t.text :secret

      t.index %i[uid provider], unique: true

      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at, null: false
      t.datetime :last_sign_in_at, null: false
      t.inet :current_sign_in_ip, null: false
      t.inet :last_sign_in_ip, null: false

      t.timestamps null: false
    end
  end
end
