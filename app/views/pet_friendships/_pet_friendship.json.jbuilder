json.extract! pet_friendship, :id, :requester_pet_id, :receiver_pet_id, :requested_by_user_id, :status, :accepted_at, :created_at, :updated_at
json.url pet_friendship_url(pet_friendship, format: :json)
