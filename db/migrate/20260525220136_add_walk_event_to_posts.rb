class AddWalkEventToPosts < ActiveRecord::Migration[8.0]
  def change
    add_reference :posts, :walk_event, null: true, foreign_key: true
  end
end
