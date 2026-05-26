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
