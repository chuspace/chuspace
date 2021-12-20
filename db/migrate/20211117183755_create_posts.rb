# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :posts do |t|
      t.string :blob_path, null: false
      t.references :blog, null: false, foreign_key: true
      t.references :author, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :posts, %i[blog_id blob_path], unique: true, algorithm: :concurrently
    add_index :posts, :blob_path, algorithm: :concurrently
    add_column :posts, :visibility, :post_visibility_enum_type, index: { algorithm: :concurrently }
  end
end
