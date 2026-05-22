# == Schema Information
#
# Table name: photos
#
#  id             :bigint           not null, primary key
#  caption        :text
#  comments_count :integer          default(0)
#  image          :string
#  likes_count    :integer          default(0)
#  pinned         :boolean          default(FALSE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  owner_id       :bigint           not null
#
# Indexes
#
#  index_photos_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
class Photo < ApplicationRecord
  has_one_attached :image, dependent: :purge_later
  
  belongs_to :owner, class_name: "User", counter_cache: true

  validates :caption, presence: true
  validates :image, presence: true

  scope :latest, -> { order(created_at: :desc) }
  scope :pinned, -> { where(pinned: true) }
  scope :unpinned, -> { where(pinned: false) }
end
