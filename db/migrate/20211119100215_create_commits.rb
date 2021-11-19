class CreateCommits < ActiveRecord::Migration[7.0]
  def change
    create_table :commits do |t|
      t.references :blob, null: false, foreign_key: true
      t.text :message, null: false
      t.text :sha, null: false
      t.string :author_name
      t.string :author_email
      t.timestamp :committed_at

      t.timestamps
    end
  end
end
