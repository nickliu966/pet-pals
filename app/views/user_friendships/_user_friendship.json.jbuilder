json.extract! user_friendship, :id, :requester_id, :receiver_id, :status, :accepted_at, :created_at, :updated_at
json.url user_friendship_url(user_friendship, format: :json)
