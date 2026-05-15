# == Schema Information
#
# Table name: user_friendships
#
#  id           :bigint           not null, primary key
#  accepted_at  :datetime
#  status       :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  receiver_id  :integer
#  requester_id :integer
#
class UserFriendship < ApplicationRecord
end
