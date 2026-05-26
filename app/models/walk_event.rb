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

  has_many :posts, dependent: :nullify

  enum :visibility, {
    everyone: "everyone",
    user_friends_only: "user_friends_only",
    pet_friends_only: "pet_friends_only",
    friends_of_either: "friends_of_either",
  }

  enum :status, {
    scheduled: "scheduled",
    full: "full",
    cancelled: "cancelled",
    completed: "completed",
  }

  validates :title, presence: true
  validates :location_name, presence: true
  validates :start_time, presence: true

  validates :duration_minutes,
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
    confirmed_participants.count >= max_participants
  end

  def display_status
    if status == "cancelled"
      "cancelled"
    elsif start_time.present? &&
          duration_minutes.present? &&
          Time.current > start_time + duration_minutes.minutes
      "completed"
    else
      "scheduled"
    end
  end

  def invited_participants
    walk_participants.where(status: "invited")
  end

  def confirmed_participants
    walk_participants.where(status: ["joined", "attended"])
  end

  def joined_by?(user)
    return false if user.nil?

    confirmed_participants.exists?(user: user)
  end

  def involved_user?(user)
    host_user == user || joined_by?(user)
  end

  def past?
    start_time.present? && start_time < Time.current
  end

  def attendance_claimable_by?(user)
    return false if user.nil?
    return false if involved_user?(user)

    completed? || past?
  end

  def invitable_user_friends_for(user)
    friend_users = (user.owner_friends + user.friended_by_users).uniq

    existing_user_ids =
      walk_participants
        .where.not(status: "cancelled")
        .pluck(:user_id)

    friend_users.reject do |friend|
      existing_user_ids.include?(friend.id)
    end
  end

  def invitable_pet_friends_for(user)
    pet_friends = []

    user.pets.each do |pet|
      pet_friends += pet.pet_friends
      pet_friends += pet.friended_by_pets
    end

    pet_friends = pet_friends.uniq

    existing_pet_ids =
      walk_participants
        .where.not(status: "cancelled")
        .where.not(pet_id: nil)
        .pluck(:pet_id)

    pet_friends.reject do |pet|
      existing_pet_ids.include?(pet.id)
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "title",
      "note",
      "location_name",
      "start_time",
      "visibility",
      "status",
      "created_at",
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    [
      "host_user",
      "walk_participants",
      "posts",
    ]
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
