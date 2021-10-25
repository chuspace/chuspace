# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    enable_extension 'citext'

    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name
      t.citext :username
      t.string :email, null: false

      # track associations
      t.integer :blogs_count, null: false, default: 0
      t.integer :storages_count, null: false, default: 0
      t.integer :templates_count, null: false, default: 0

      # Track logins
      t.integer :sign_in_count, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip

      t.timestamps null: false
    end

    add_index :users, :username, algorithm: :concurrently, unique: true
    add_index :users, :email, algorithm: :concurrently, unique: true
  end
end
