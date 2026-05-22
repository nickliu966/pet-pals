class AddUserDefaultsAndConstraints < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :username, false

    add_column :users, :private, :boolean, null: false, default: false
    add_column :users, :likes_count, :integer, null: false, default: 0
    add_column :users, :comments_count, :integer, null: false, default: 0
    add_column :users, :posts_count, :integer, null: false, default: 0
  end
end
