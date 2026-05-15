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
end
