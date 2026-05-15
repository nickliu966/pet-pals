# == Schema Information
#
# Table name: pets
#
#  id           :bigint           not null, primary key
#  bio          :text
#  birthday     :date
#  breed        :string
#  energy_level :string
#  gender       :string
#  image_url    :string
#  name         :string
#  neutered     :boolean
#  size         :string
#  species      :string
#  temperament  :string
#  vaccinated   :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_pets_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Pet < ApplicationRecord
  belongs_to :user

  has_many :posts, dependent: :nullify

  has_many :sent_pet_friendships,
           foreign_key: :requester_pet_id,
           class_name: "PetFriendship",
           dependent: :destroy

  has_many :accepted_sent_pet_friendships,
           -> { accepted },
           foreign_key: :requester_pet_id,
           class_name: "PetFriendship"

  has_many :received_pet_friendships,
           foreign_key: :receiver_pet_id,
           class_name: "PetFriendship",
           dependent: :destroy

  has_many :accepted_received_pet_friendships,
           -> { accepted },
           foreign_key: :receiver_pet_id,
           class_name: "PetFriendship"

  has_many :pending_received_pet_friendships,
           -> { pending },
           foreign_key: :receiver_pet_id,
           class_name: "PetFriendship"

  has_many :pet_friends,
           through: :accepted_sent_pet_friendships,
           source: :receiver_pet

  has_many :pet_followers,
           through: :accepted_received_pet_friendships,
           source: :requester_pet

  has_many :pending_pet_friends,
           through: :pending_received_pet_friendships,
           source: :requester_pet

  has_many :hosted_walk_events,
           foreign_key: :host_pet_id,
           class_name: "WalkEvent",
           dependent: :destroy

  has_many :walk_participants, dependent: :destroy

  has_many :joined_walk_events,
           through: :walk_participants,
           source: :walk_event

  has_many :friended_by_pets,
         through: :accepted_received_pet_friendships,
         source: :requester_pet

  validates :name, presence: true
  validates :species, presence: true

  def friends_with?(other_pet)
    pet_friends.exists?(id: other_pet.id) ||
      friended_by_pets.exists?(id: other_pet.id)
  end
end
