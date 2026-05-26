class MakePetOptionalForPosts < ActiveRecord::Migration[8.0]
  def change
    change_column_null :posts, :pet_id, true
  end
end
