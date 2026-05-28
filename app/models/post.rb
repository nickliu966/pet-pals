# == Schema Information
#
# Table name: posts
#
#  id              :bigint           not null, primary key
#  body            :text
#  comments_count  :integer          default(0), not null
#  image_url       :string
#  latitude        :decimal(, )
#  likes_count     :integer          default(0), not null
#  location_name   :string
#  longitude       :decimal(, )
#  visibility      :string           default("everyone"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  google_place_id :string
#  pet_id          :bigint
#  user_id         :bigint           not null
#  walk_event_id   :bigint
#
# Indexes
#
#  index_posts_on_pet_id         (pet_id)
#  index_posts_on_user_id        (user_id)
#  index_posts_on_walk_event_id  (walk_event_id)
#
# Foreign Keys
#
#  fk_rails_...  (pet_id => pets.id)
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (walk_event_id => walk_events.id)
#
class Post < ApplicationRecord
  include NearbySearchable

  has_many_attached :images

  belongs_to :user
  belongs_to :pet, optional: true
  belongs_to :walk_event, optional: true

  has_many :comments, dependent: :destroy

  has_many :likes, dependent: :destroy

  has_many :fans,
           through: :likes,
           source: :fan

  enum :visibility, {
    everyone: "everyone",
    user_friends_only: "user_friends_only",
    pet_friends_only: "pet_friends_only",
    friends_of_either: "friends_of_either",
  }

  validate :walk_event_must_be_available_to_user

  scope :default_order, -> { order(created_at: :desc) }

  def self.visible_to(user)
    following_user_ids =
      UserFriendship
        .where(requester: user, status: "accepted")
        .pluck(:receiver_id)

    follower_user_ids =
      UserFriendship
        .where(receiver: user, status: "accepted")
        .pluck(:requester_id)

    friend_user_ids = following_user_ids & follower_user_ids

    user_pet_ids = user.pets.pluck(:id)

    pet_friend_ids =
      PetFriendship
        .accepted
        .where(requester_pet_id: user_pet_ids)
        .pluck(:receiver_pet_id) +
      PetFriendship
        .accepted
        .where(receiver_pet_id: user_pet_ids)
        .pluck(:requester_pet_id)

    post_ids = []

    post_ids += where(user: user).pluck(:id)
    post_ids += where(visibility: "everyone").pluck(:id)

    post_ids +=
      where(user_id: friend_user_ids)
        .where(visibility: ["user_friends_only", "friends_of_either"])
        .pluck(:id)

    post_ids +=
      where(pet_id: pet_friend_ids.uniq)
        .where(visibility: ["pet_friends_only", "friends_of_either"])
        .pluck(:id)

    where(id: post_ids.uniq)
  end

  private

  def set_defaults
    self.visibility ||= "everyone"
  end

  def walk_event_must_be_available_to_user
    return if walk_event.blank? || user.blank?

    return if walk_event.host_user == user
    return if walk_event.walk_participants.exists?(user: user)

    errors.add(:walk_event, "must be one you hosted or joined")
  end
end
