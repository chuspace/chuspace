# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'citext'

    create_table :users do |t|
      t.string :name
      t.citext :username, index: { unique: true }
      t.string :email_ciphertext, null: false
      t.string :email_bidx, null: false
      t.boolean :onboarded, null: false, default: false, index: true

      # Track logins
      t.integer :sign_in_count, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip

      t.timestamps null: false
    end

    add_index :users, :email_bidx, unique: true
  end
end
