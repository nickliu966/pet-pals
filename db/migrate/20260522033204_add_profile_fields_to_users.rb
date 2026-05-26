class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :display_name, :string
    add_column :users, :website, :string
  end
end
