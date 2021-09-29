# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    enable_extension 'citext'

    create_table :users do |t|
      t.string :name
      t.citext :username
      t.string :email_ciphertext, null: false
      t.string :email_bidx, null: false

      # Track logins
      t.integer :sign_in_count, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip

      t.timestamps null: false
    end

    add_index :users, :username, algorithm: :concurrently, unique: true
    add_index :users, :email_bidx, algorithm: :concurrently, unique: true
  end
end
