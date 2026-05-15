# == Schema Information
#
# Table name: walk_participants
#
#  id            :bigint           not null, primary key
#  joined_at     :datetime
#  status        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  pet_id        :bigint           not null
#  user_id       :bigint           not null
#  walk_event_id :bigint           not null
#
# Indexes
#
#  index_walk_participants_on_pet_id         (pet_id)
#  index_walk_participants_on_user_id        (user_id)
#  index_walk_participants_on_walk_event_id  (walk_event_id)
#
# Foreign Keys
#
#  fk_rails_...  (pet_id => pets.id)
#  fk_rails_...  (user_id => users.id)
#  fk_rails_...  (walk_event_id => walk_events.id)
#
class WalkParticipant < ApplicationRecord
  belongs_to :walk_event
  belongs_to :user
  belongs_to :pet
end
