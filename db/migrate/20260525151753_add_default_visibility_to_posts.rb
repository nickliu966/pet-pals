class AddDefaultVisibilityToPosts < ActiveRecord::Migration[8.0]
  def change
    change_column_default :posts, :visibility, from: nil, to: "everyone"
  end
end
