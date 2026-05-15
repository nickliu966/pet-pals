json.extract! walk_event, :id, :host_user_id, :host_pet_id, :title, :note, :location_name, :latitude, :longitude, :start_time, :duration_minutes, :visibility, :max_participants, :status, :created_at, :updated_at
json.url walk_event_url(walk_event, format: :json)
