class CreateWalkEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :walk_events do |t|
      t.integer :host_user_id
      t.integer :host_pet_id
      t.string :title
      t.text :note
      t.string :location_name
      t.decimal :latitude
      t.decimal :longitude
      t.datetime :start_time
      t.integer :duration_minutes
      t.integer :visibility
      t.integer :max_participants
      t.integer :status

      t.timestamps
    end
  end
end
