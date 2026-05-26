class CreatePetFriendships < ActiveRecord::Migration[8.0]
  def change
    create_table :pet_friendships do |t|
      t.integer :requester_pet_id
      t.integer :receiver_pet_id
      t.integer :requested_by_user_id
      t.string :status, null: false, default: "pending"
      t.datetime :accepted_at

      t.timestamps
    end
  end
end
