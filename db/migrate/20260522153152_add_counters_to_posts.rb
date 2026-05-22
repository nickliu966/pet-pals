class AddCountersToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :likes_count, :integer, null: false, default: 0 unless column_exists?(:posts, :likes_count)
    add_column :posts, :comments_count, :integer, null: false, default: 0 unless column_exists?(:posts, :comments_count)
  end
end
