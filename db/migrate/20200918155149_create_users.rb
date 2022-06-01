# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name
      t.string :username, null: false
      t.string :email, null: false

      # Store readme
      t.text :readme

      # track associations
      t.bigint :publications_count, null: false, default: 0

      # Track logins
      t.bigint :sign_in_count, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      t.timestamps null: false
    end

    add_index :users, :username, algorithm: :default, unique: true
    add_index :users, :email, algorithm: :default, unique: true
  end
end
