class CreateUserFriendships < ActiveRecord::Migration[8.0]
  def change
    create_table :user_friendships do |t|
      t.integer :requester_id
      t.integer :receiver_id
      t.string :status, null: false, default: "pending"
      t.datetime :accepted_at

      t.timestamps
    end
  end
end
