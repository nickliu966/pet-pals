json.extract! pet, :id, :user_id, :name, :species, :breed, :gender, :birthday, :size, :energy_level, :temperament, :vaccinated, :neutered, :bio, :created_at, :updated_at
json.url pet_url(pet, format: :json)
