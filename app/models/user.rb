# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  bio                    :text
#  city                   :string
#  comments_count         :integer          default(0), not null
#  display_name           :string
#  email                  :citext
#  encrypted_password     :string           default(""), not null
#  likes_count            :integer          default(0), not null
#  posts_count            :integer          default(0), not null
#  private                :boolean          default(FALSE), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  username               :citext           not null
#  website                :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#
class User < ApplicationRecord
  has_one_attached :avatar_image, dependent: :purge_later
  has_one_attached :profile_banner, dependent: :purge_later

  has_many :own_posts, foreign_key: :owner_id, class_name: "Post", dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :pets, dependent: :destroy

  has_many :posts, dependent: :destroy

  has_many :comments,
           foreign_key: :author_id,
           dependent: :destroy

  has_many :likes,
           foreign_key: :fan_id,
           dependent: :destroy

  has_many :liked_posts,
           through: :likes,
           source: :post

  has_many :sent_user_friendships,
           foreign_key: :requester_id,
           class_name: "UserFriendship",
           dependent: :destroy

  has_many :accepted_sent_user_friendships,
           -> { accepted },
           foreign_key: :requester_id,
           class_name: "UserFriendship"

  has_many :received_user_friendships,
           foreign_key: :receiver_id,
           class_name: "UserFriendship",
           dependent: :destroy

  has_many :accepted_received_user_friendships,
           -> { accepted },
           foreign_key: :receiver_id,
           class_name: "UserFriendship"

  has_many :pending_received_user_friendships,
           -> { pending },
           foreign_key: :receiver_id,
           class_name: "UserFriendship"

  has_many :owner_friends,
           through: :accepted_sent_user_friendships,
           source: :receiver

  has_many :owner_followers,
           through: :accepted_received_user_friendships,
           source: :requester

  has_many :pending_owner_friends,
           through: :pending_received_user_friendships,
           source: :requester

  has_many :hosted_walk_events,
           foreign_key: :host_user_id,
           class_name: "WalkEvent",
           dependent: :destroy

  has_many :walk_participants, dependent: :destroy

  has_many :joined_walk_events,
           through: :walk_participants,
           source: :walk_event

  has_many :friended_by_users,
           through: :accepted_received_user_friendships,
           source: :requester

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  validates :username,
    presence: true,
    uniqueness: true,
    format: {
      with: /\A[\w_\.]+\z/i,
      message: "can only contain letters, numbers, periods, and underscores",
    }

  validates :website, url: { allow_blank: true }

  attr_accessor :remove_profile_banner
  after_save :purge_profile_banner, if: :remove_profile_banner

  before_create :set_default_avatar

  def set_default_avatar
    image = "https://res.cloudinary.com/dzhwwlb9e/image/upload/v1773240782/960px-Default_pfp.svg_dpntzd_ga9htr.png"
    avatar_image.attach(
      io: URI.open(image),
      filename: image.split("/").last,
      content_type: "image/jpg"
    )
  end

  def purge_profile_banner
    profile_banner.purge_later
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "username" ]
  end

  def friends_with?(other_user)
    owner_friends.exists?(id: other_user.id) ||
      friended_by_users.exists?(id: other_user.id)
  end
end
