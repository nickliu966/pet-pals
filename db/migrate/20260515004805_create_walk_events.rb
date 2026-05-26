class CreateWalkEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :walk_events do |t|
      t.references :host_user, null: false, foreign_key: { to_table: :users }
      t.references :host_pet, null: false, foreign_key: { to_table: :pets }

      t.string :title, null: false
      t.text :note
      t.string :location_name, null: false
      t.decimal :latitude
      t.decimal :longitude
      t.datetime :start_time, null: false
      t.integer :duration_minutes, null: false
      t.string :visibility, null: false, default: "friends_of_either"
      t.integer :max_participants, null: false, default: 5
      t.string :status, null: false, default: "scheduled"

      t.timestamps
    end
  end
end
