# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  bio        :text
#  city       :string
#  email      :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
end
