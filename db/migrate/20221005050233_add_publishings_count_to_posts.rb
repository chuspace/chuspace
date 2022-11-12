class AddPublishingsCountToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :publishings_count, :bigint, default: 0
  end
end
