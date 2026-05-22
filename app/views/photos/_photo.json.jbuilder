json.extract! photo, :id, :image, :caption, :owner_id, :pinned, :comments_count, :likes_count, :created_at, :updated_at
json.url photo_url(photo, format: :json)
