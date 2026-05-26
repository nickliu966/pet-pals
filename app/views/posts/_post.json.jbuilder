json.extract! post, :id, :user_id, :pet_id, :body, :visibility, :created_at, :updated_at
json.url post_url(post, format: :json)
