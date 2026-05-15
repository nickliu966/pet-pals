# == Schema Information
#
# Table name: posts
#
#  id         :bigint           not null, primary key
#  body       :text
#  visibility :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pet_id     :bigint           not null
#  user_id    :bigint           not null
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
  belongs_to :pet
end
