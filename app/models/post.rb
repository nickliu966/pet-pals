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
#  visibility      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  google_place_id :string
#  pet_id          :bigint
#  user_id         :bigint           not null
#
# Indexes
#
#  index_posts_on_pet_id   (pet_id)
#  index_posts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (pet_id => pets.id)
#  fk_rails_...  (user_id => users.id)
#
class Post < ApplicationRecord
  belongs_to :user
  belongs_to :pet, optional: true

  has_many :comments, dependent: :destroy

  has_many :likes, dependent: :destroy

  has_many :fans,
           through: :likes,
           source: :fan

  enum :visibility, {
    everyone: "everyone",
    user_friends_only: "user_friends_only",
    pet_friends_only: "pet_friends_only",
    friends_of_either: "friends_of_either"
  }

  validates :body, presence: true

  scope :default_order, -> { order(created_at: :desc) }
end
