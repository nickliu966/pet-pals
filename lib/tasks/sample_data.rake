desc "Fill the database tables with some sample data"
task({ sample_data: :environment }) do
  starting = Time.now

  Faker::Config.random = Random.new(42)

  puts "Deleting old data..."

  WalkParticipant.destroy_all
  WalkEvent.destroy_all
  Like.destroy_all
  Comment.destroy_all
  Post.destroy_all
  PetFriendship.destroy_all
  UserFriendship.destroy_all
  Pet.destroy_all
  User.destroy_all

  puts "Creating users..."

  users_data = [
    { name: "Nick", email: "nick@example.com", city: "Chicago" },
    { name: "Sarah", email: "sarah@example.com", city: "Chicago" },
    { name: "Emily", email: "emily@example.com", city: "Chicago" },
    { name: "Jason", email: "jason@example.com", city: "Chicago" },
    { name: "Maya", email: "maya@example.com", city: "Chicago" },
  ]

  users = users_data.map do |attrs|
    User.create!(
      name: attrs[:name],
      email: attrs[:email],
      city: attrs[:city],
      bio: "#{attrs[:name]} loves pets, parks, and weekend walks.",
    )
  end

  nick, sarah, emily, jason, maya = users

  pet_images = [
    "https://images.unsplash.com/photo-1552053831-71594a27632d",
    "https://images.unsplash.com/photo-1548199973-03cce0bbc87b",
    "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba",
    "https://images.unsplash.com/photo-1587300003388-59208cc962cb",
    "https://images.unsplash.com/photo-1517849845537-4d257902454a",
  ]

  puts "Creating pets..."

  max = Pet.create!(
    user: nick,
    name: "Max",
    species: "Dog",
    breed: "Golden Retriever",
    gender: "Male",
    size: "Large",
    energy_level: "High",
    temperament: "Playful",
    vaccinated: true,
    neutered: true,
    bio: "Friendly, energetic, and obsessed with tennis balls.",
    image_url: pet_images[0],
  )

  coco = Pet.create!(
    user: sarah,
    name: "Coco",
    species: "Dog",
    breed: "Corgi",
    gender: "Female",
    size: "Small",
    energy_level: "Medium",
    temperament: "Confident",
    vaccinated: true,
    neutered: true,
    bio: "Small but brave. Loves calm dog friends.",
    image_url: pet_images[1],
  )

  luna = Pet.create!(
    user: emily,
    name: "Luna",
    species: "Cat",
    breed: "British Shorthair",
    gender: "Female",
    size: "Small",
    energy_level: "Low",
    temperament: "Calm",
    vaccinated: true,
    neutered: true,
    bio: "Quiet, judgmental, and secretly affectionate.",
    image_url: pet_images[2],
  )

  rocky = Pet.create!(
    user: jason,
    name: "Rocky",
    species: "Dog",
    breed: "Beagle",
    gender: "Male",
    size: "Medium",
    energy_level: "High",
    temperament: "Curious",
    vaccinated: true,
    neutered: true,
    bio: "Always sniffing something important.",
    image_url: pet_images[3],
  )

  bella = Pet.create!(
    user: maya,
    name: "Bella",
    species: "Dog",
    breed: "Samoyed",
    gender: "Female",
    size: "Large",
    energy_level: "Medium",
    temperament: "Friendly",
    vaccinated: true,
    neutered: true,
    bio: "Very fluffy and very social.",
    image_url: pet_images[4],
  )

  pets = [max, coco, luna, rocky, bella]

  puts "Creating user friendships..."

  UserFriendship.create!(
    requester: nick,
    receiver: sarah,
    status: :accepted,
    accepted_at: Time.current,
  )

  UserFriendship.create!(
    requester: nick,
    receiver: jason,
    status: :accepted,
    accepted_at: Time.current,
  )

  UserFriendship.create!(
    requester: maya,
    receiver: nick,
    status: :pending,
  )

  puts "Creating pet friendships..."

  PetFriendship.create!(
    requester_pet: max,
    receiver_pet: coco,
    requested_by_user: nick,
    status: :accepted,
    accepted_at: Time.current,
  )

  PetFriendship.create!(
    requester_pet: max,
    receiver_pet: rocky,
    requested_by_user: nick,
    status: :accepted,
    accepted_at: Time.current,
  )

  PetFriendship.create!(
    requester_pet: bella,
    receiver_pet: max,
    requested_by_user: maya,
    status: :pending,
  )

  puts "Creating posts..."

  posts_data = [
    [nick, max, "Max has way too much energy today. Definitely needs a long walk.", pet_images[0]],
    [sarah, coco, "Coco met Max today and immediately acted like she owned the park.", pet_images[1]],
    [emily, luna, "Luna does not walk, but she strongly supports other pets walking.", pet_images[2]],
    [jason, rocky, "Rocky found one leaf and treated it like a major discovery.", pet_images[3]],
    [maya, bella, "Bella is looking for gentle dog friends nearby.", pet_images[4]],
  ]

  posts = posts_data.map do |user, pet, body, image_url|
    Post.create!(
      user: user,
      pet: pet,
      body: body,
      visibility: :everyone,
      image_url: image_url,
    )
  end

  puts "Creating comments and likes..."

  posts.each do |post|
    users.sample(2).each do |user|
      next if user == post.user

      Comment.create!(
        post: post,
        author: user,
        body: Faker::Quote.famous_last_words,
      )
    end

    users.sample(3).each do |user|
      Like.find_or_create_by!(
        post: post,
        fan: user,
      )
    end
  end

  puts "Creating walk events..."

  walk_1 = WalkEvent.create!(
    host_user: nick,
    host_pet: max,
    title: "Evening walk at Washington Park",
    location_name: "Washington Park",
    start_time: 2.hours.from_now,
    duration_minutes: 45,
    visibility: :friends_of_either,
    max_participants: 5,
    status: :scheduled,
    note: "Max has extra energy today. Friendly dogs welcome.",
  )

  walk_2 = WalkEvent.create!(
    host_user: sarah,
    host_pet: coco,
    title: "Short walk near Hyde Park",
    location_name: "Hyde Park",
    start_time: 1.day.from_now.change(hour: 10),
    duration_minutes: 30,
    visibility: :pet_friends_only,
    max_participants: 4,
    status: :scheduled,
    note: "Coco does better with pets she already knows.",
  )

  walk_3 = WalkEvent.create!(
    host_user: maya,
    host_pet: bella,
    title: "Weekend social walk",
    location_name: "Lincoln Park",
    start_time: 2.days.from_now.change(hour: 15),
    duration_minutes: 60,
    visibility: :everyone,
    max_participants: 6,
    status: :scheduled,
    note: "Open walk for friendly pets.",
  )

  WalkParticipant.create!(
    walk_event: walk_1,
    user: sarah,
    pet: coco,
    status: :joined,
    joined_at: Time.current,
  )

  WalkParticipant.create!(
    walk_event: walk_1,
    user: jason,
    pet: rocky,
    status: :joined,
    joined_at: Time.current,
  )

  ending = Time.now

  puts "Done."
  puts "It took #{(ending - starting).round(2)} seconds."
  puts "Users: #{User.count}"
  puts "Pets: #{Pet.count}"
  puts "User friendships: #{UserFriendship.count}"
  puts "Pet friendships: #{PetFriendship.count}"
  puts "Posts: #{Post.count}"
  puts "Comments: #{Comment.count}"
  puts "Likes: #{Like.count}"
  puts "Walk events: #{WalkEvent.count}"
  puts "Walk participants: #{WalkParticipant.count}"
end
