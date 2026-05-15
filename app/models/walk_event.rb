# == Schema Information
#
# Table name: walk_events
#
#  id               :bigint           not null, primary key
#  duration_minutes :integer          not null
#  latitude         :decimal(, )
#  location_name    :string           not null
#  longitude        :decimal(, )
#  max_participants :integer          default(5), not null
#  note             :text
#  start_time       :datetime         not null
#  status           :string           default("scheduled"), not null
#  title            :string           not null
#  visibility       :string           default("friends_of_either"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  host_pet_id      :bigint           not null
#  host_user_id     :bigint           not null
#
# Indexes
#
#  index_walk_events_on_host_pet_id   (host_pet_id)
#  index_walk_events_on_host_user_id  (host_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (host_pet_id => pets.id)
#  fk_rails_...  (host_user_id => users.id)
#
class WalkEvent < ApplicationRecord
  belongs_to :host_user,
             class_name: "User"

  belongs_to :host_pet,
             class_name: "Pet"

  has_many :walk_participants, dependent: :destroy

  has_many :participant_users,
           through: :walk_participants,
           source: :user

  has_many :participant_pets,
           through: :walk_participants,
           source: :pet

  enum :visibility, {
    everyone: "everyone",
    user_friends_only: "user_friends_only",
    pet_friends_only: "pet_friends_only",
    friends_of_either: "friends_of_either"
  }

  enum :status, {
    scheduled: "scheduled",
    full: "full",
    cancelled: "cancelled",
    completed: "completed"
  }

  validates :title, presence: true
  validates :location_name, presence: true
  validates :start_time, presence: true

  validates :duration_minutes,
            numericality: { greater_than: 0 }

  validates :max_participants,
            numericality: { greater_than: 0 }

  validate :host_pet_must_belong_to_host_user

  before_validation :set_defaults

  scope :upcoming, -> { where(start_time: Time.current..).order(start_time: :asc) }
  scope :default_order, -> { order(start_time: :asc) }

  def eligible_pets_for(user)
    user.pets.select do |pet|
      joinable_by?(user, pet)
    end
  end

  def joinable_by?(user, pet)
    return false if user.nil?
    return false if pet.nil?
    return false unless scheduled?
    return false if user == host_user
    return false unless pet.user == user
    return false if full_by_count?
    return false if walk_participants.joined.exists?(pet: pet)

    case visibility
    when "everyone"
      true
    when "user_friends_only"
      host_user.friends_with?(user)
    when "pet_friends_only"
      host_pet.friends_with?(pet)
    when "friends_of_either"
      host_user.friends_with?(user) || host_pet.friends_with?(pet)
    else
      false
    end
  end

  def full_by_count?
    walk_participants.joined.count >= max_participants
  end

  private

  def set_defaults
    self.visibility ||= "friends_of_either"
    self.status ||= "scheduled"
    self.max_participants ||= 5
  end

  def host_pet_must_belong_to_host_user
    return if host_pet.nil? || host_user.nil?

    unless host_pet.user_id == host_user.id
      errors.add(:host_pet, "must belong to host user")
    end
  end
end
