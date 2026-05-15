# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  bio        :text
#  city       :string
#  email      :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
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

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  def friends_with?(other_user)
    owner_friends.exists?(id: other_user.id) ||
      friended_by_users.exists?(id: other_user.id)
  end
end
