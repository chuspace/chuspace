class CreateTemplates < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    create_table :templates do |t|
      t.string :name, null: false
      t.string :description
      t.string :permalink, null: false
      t.string :language, null: false
      t.string :framework, null: false
      t.string :css

      t.references :storage, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :mirror_path
      t.string :git_source, null: false
      t.string :preview_url

      t.string :articles_folder, null: false
      t.string :drafts_folder, null: false
      t.string :assets_folder, null: false
      t.string :readme, null: false, default: 'README.md'
      t.boolean :default, null: false, default: false
      t.boolean :approved, null: false, default: false
      t.boolean :system, null: false, default: false

      t.timestamps
    end

    add_column :templates, :visibility, :template_visibility_enum_type, default: :public
    add_index :templates, :default, algorithm: :concurrently
    add_index :templates, :approved, algorithm: :concurrently
    add_index :templates, :system, algorithm: :concurrently
    add_index :templates, :visibility, algorithm: :concurrently
    add_index :templates, :framework, algorithm: :concurrently
    add_index :templates, :css, algorithm: :concurrently
    add_index :templates, :language, algorithm: :concurrently
    add_index :templates, :permalink, unique: true, algorithm: :concurrently
  end
end
