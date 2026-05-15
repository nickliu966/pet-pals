# == Schema Information
#
# Table name: pet_friendships
#
#  id                   :bigint           not null, primary key
#  accepted_at          :datetime
#  status               :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  receiver_pet_id      :integer
#  requested_by_user_id :integer
#  requester_pet_id     :integer
#
class PetFriendship < ApplicationRecord
end
