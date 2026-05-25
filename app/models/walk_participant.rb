# == Schema Information
#
# Table name: walk_participants
#
#  id            :bigint           not null, primary key
#  joined_at     :datetime
#  status        :string           default("joined"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  pet_id        :bigint
#  user_id       :bigint           not null
#  walk_event_id :bigint           not null
#
# Indexes
#
#  index_walk_participants_on_pet_id         (pet_id)
#  index_walk_participants_on_user_id        (user_id)
#  index_walk_participants_on_walk_event_id  (walk_event_id)
#
# Foreign Keys
#
#  fk_rails_...  (pet_id => pets.id)
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (walk_event_id => walk_events.id)
#
class WalkParticipant < ApplicationRecord
  belongs_to :walk_event
  belongs_to :user
  belongs_to :pet, optional: true

  enum :status, {
    joined: "joined",
    cancelled: "cancelled",
    attended: "attended",
    no_show: "no_show"
  }

  validates :pet_id,
            uniqueness: {
              scope: :walk_event_id,
              message: "has already joined this walk"
            }

  validate :pet_must_belong_to_user
  validate :walk_must_be_joinable

  before_validation :set_defaults

  private

  def set_defaults
    self.status ||= "joined"
    self.joined_at ||= Time.current
  end

  def pet_must_belong_to_user
    return if pet.nil? || user.nil?

    unless pet.user_id == user.id
      errors.add(:pet, "must belong to the joining user")
    end
  end

  def walk_must_be_joinable
    return if walk_event.nil? || user.nil? || pet.nil?
    return if status != "joined"

    unless walk_event.joinable_by?(user, pet)
      errors.add(:walk_event, "is not available to this user and pet")
    end
  end
end
