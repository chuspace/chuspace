# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'citext'

    create_table :users do |t|
      t.string :name
      t.citext :username, index: { unique: true }
      t.string :email_ciphertext, null: false
      t.string :email_bidx, null: false, index: { unique: true }
      t.text :bio

      # Track logins
      t.integer :sign_in_count, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip

      t.timestamps null: false
    end
  end
end
