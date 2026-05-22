class ChangeUserEmailAndUsernameToCitext < ActiveRecord::Migration[8.0]
  def change
    enable_extension "citext"

    change_column :users, :email, :citext
    change_column :users, :name, :citext

    add_index :users, :email, unique: true unless index_exists?(:users, :email)
    add_index :users, :name, unique: true unless index_exists?(:users, :username)
  end
end
