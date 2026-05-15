# == Schema Information
#
# Table name: comments
#
#  id                :bigint           not null, primary key
#  body              :text             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  author_id         :bigint           not null
#  parent_comment_id :integer
#  post_id           :bigint           not null
#
# Indexes
#
#  index_comments_on_author_id  (author_id)
#  index_comments_on_post_id    (post_id)
#
# Foreign Keys
#
#  fk_rails_...  (author_id => users.id)
#  fk_rails_...  (post_id => posts.id)
#
class Comment < ApplicationRecord
  belongs_to :author, class_name: "User"
  belongs_to :post

  belongs_to :parent_comment,
             class_name: "Comment",
             optional: true

  has_many :replies,
           foreign_key: :parent_comment_id,
           class_name: "Comment",
           dependent: :destroy

  validates :body, presence: true

  scope :default_order, -> { order(created_at: :asc) }
end
