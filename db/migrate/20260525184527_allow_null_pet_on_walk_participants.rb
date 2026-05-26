class AllowNullPetOnWalkParticipants < ActiveRecord::Migration[8.0]
  def change
    change_column_null :walk_participants, :pet_id, true
  end
end
