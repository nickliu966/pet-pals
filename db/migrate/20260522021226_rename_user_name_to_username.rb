class RenameUserNameToUsername < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :name, :username
  end
end
