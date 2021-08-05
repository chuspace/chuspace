class CreateBlogs < ActiveRecord::Migration[6.1]
  def change
    create_table :blogs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_repo_name, index: { unique: true}
      t.string :posts_folder
      t.string :drafts_folder
      t.string :assets_folder
      t.boolean :default, default: false, null: false, index: true

      t.timestamps
    end
  end
end
