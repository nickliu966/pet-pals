class AddGooglePlaceIdToWalkEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :walk_events, :google_place_id, :string
  end
end
