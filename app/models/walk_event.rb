# == Schema Information
#
# Table name: walk_events
#
#  id               :bigint           not null, primary key
#  duration_minutes :integer
#  latitude         :decimal(, )
#  location_name    :string
#  longitude        :decimal(, )
#  max_participants :integer
#  note             :text
#  start_time       :datetime
#  status           :integer
#  title            :string
#  visibility       :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  host_pet_id      :integer
#  host_user_id     :integer
#
class WalkEvent < ApplicationRecord
end
