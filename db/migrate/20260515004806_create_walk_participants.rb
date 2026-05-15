class CreateWalkParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :walk_participants do |t|
      t.references :walk_event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :pet, null: false, foreign_key: true
      t.integer :status
      t.datetime :joined_at

      t.timestamps
    end
  end
end
