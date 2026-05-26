class AddLocationToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :location_name, :string
    add_column :posts, :latitude, :decimal
    add_column :posts, :longitude, :decimal
    add_column :posts, :google_place_id, :string
  end
end
