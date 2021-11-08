class CreateImages < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :images do |t|
      t.text :blob_path
      t.text :base64_blob_path
      t.references :blog, null: false, foreign_key: true
      t.timestamps
    end

    add_index :images, %i[blob_path blog_id], unique: true, algorithm: :concurrently
  end
end
