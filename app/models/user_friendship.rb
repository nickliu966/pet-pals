# == Schema Information
#
# Table name: user_friendships
#
#  id           :bigint           not null, primary key
#  accepted_at  :datetime
#  status       :string           default("pending"), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  receiver_id  :integer
#  requester_id :integer
#
class UserFriendship < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :receiver, class_name: "User"

  enum :status, {
    pending: "pending",
    accepted: "accepted",
    declined: "declined"
  }

  validates :receiver_id,
            uniqueness: {
              scope: :requester_id,
              message: "already requested"
            }

  validate :users_cant_friend_themselves

  scope :accepted_between, ->(user_a, user_b) {
    accepted.where(
      "(requester_id = :a AND receiver_id = :b) OR (requester_id = :b AND receiver_id = :a)",
      a: user_a.id,
      b: user_b.id
    )
  }

  def users_cant_friend_themselves
    if requester_id == receiver_id
      errors.add(:requester_id, "can't friend themselves")
    end
  end
end
