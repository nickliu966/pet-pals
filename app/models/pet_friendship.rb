# == Schema Information
#
# Table name: pet_friendships
#
#  id                   :bigint           not null, primary key
#  accepted_at          :datetime
#  status               :string           default("pending"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  receiver_pet_id      :integer
#  requested_by_user_id :integer
#  requester_pet_id     :integer
#
class PetFriendship < ApplicationRecord
  belongs_to :requester_pet, class_name: "Pet"
  belongs_to :receiver_pet, class_name: "Pet"
  belongs_to :requested_by_user, class_name: "User"

  enum :status, {
    pending: "pending",
    accepted: "accepted",
    declined: "declined"
  }

  validates :receiver_pet_id,
            uniqueness: {
              scope: :requester_pet_id,
              message: "already requested"
            }

  validate :pets_cant_friend_themselves
  validate :requesting_user_must_own_requester_pet

  scope :accepted_between, ->(pet_a, pet_b) {
    accepted.where(
      "(requester_pet_id = :a AND receiver_pet_id = :b) OR (requester_pet_id = :b AND receiver_pet_id = :a)",
      a: pet_a.id,
      b: pet_b.id
    )
  }

  def pets_cant_friend_themselves
    if requester_pet_id == receiver_pet_id
      errors.add(:requester_pet_id, "can't friend itself")
    end
  end

  def requesting_user_must_own_requester_pet
    return if requester_pet.nil? || requested_by_user.nil?

    unless requester_pet.user_id == requested_by_user.id
      errors.add(:requested_by_user, "must own the requester pet")
    end
  end
end
