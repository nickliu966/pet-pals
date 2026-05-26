# == Schema Information
#
# Table name: likes
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  fan_id     :bigint           not null
#  post_id    :bigint           not null
#
# Indexes
#
#  index_likes_on_fan_id   (fan_id)
#  index_likes_on_post_id  (post_id)
#
# Foreign Keys
#
#  fk_rails_...  (fan_id => users.id)
#  fk_rails_...  (post_id => posts.id)
#
class Like < ApplicationRecord
  belongs_to :fan,
             class_name: "User",
             counter_cache: true

  belongs_to :post, counter_cache: true

  validates :fan_id,
            uniqueness: {
              scope: :post_id,
              message: "has already liked this post"
            }
end
