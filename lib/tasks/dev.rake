desc "Fill the database tables with some sample data"
task sample_data: :environment do
  starting = Time.now

  Faker::Config.random = Random.new(42)

  ActiveRecord::Base.connection.tables.each do |table|
    next if [ "schema_migrations", "ar_internal_metadata" ].include?(table)

    quoted_table = ActiveRecord::Base.connection.quote_table_name(table)
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{quoted_table} RESTART IDENTITY CASCADE")
  end

  people = [
    {
      username: "alice",
      display_name: "Alice Smith",
      email: "alice@example.com",
      bio: "Alice loves long walks, dog parks, and meeting friendly pets.",
      website: "https://example.com/alice",
      private: false
    },
    {
      username: "nick",
      display_name: "Nick Liu",
      email: "nick@example.com",
      bio: "Nick is always looking for relaxed neighborhood walks.",
      website: "https://example.com/nick",
      private: false
    },
    {
      username: "sarah",
      display_name: "Sarah Chen",
      email: "sarah@example.com",
      bio: "Sarah and Coco are regulars at the park.",
      website: "https://example.com/sarah",
      private: false
    },
    {
      username: "emily",
      display_name: "Emily Brown",
      email: "emily@example.com",
      bio: "Emily likes small dogs, sunny walks, and weekend meetups.",
      website: "https://example.com/emily",
      private: false
    },
    {
      username: "bob",
      display_name: "Bob Wilson",
      email: "bob@example.com",
      bio: "Bob prefers quiet walks and early mornings.",
      website: "https://example.com/bob",
      private: true
    },
    {
      username: "carol",
      display_name: "Carol Davis",
      email: "carol@example.com",
      bio: "Carol likes cats, calm pets, and short walks.",
      website: "https://example.com/carol",
      private: true
    }
  ]

  pet_images = [
    "https://images.unsplash.com/photo-1552053831-71594a27632d",
    "https://images.unsplash.com/photo-1554692918-08fa0fdc9db3",
    "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba",
    "https://images.unsplash.com/photo-1583511655826-05700442b31b",
    "https://images.unsplash.com/photo-1548199973-03cce0bbc87b",
    "https://images.unsplash.com/photo-1518791841217-8f162f1e1131"
  ]

  post_images = [
    "https://images.unsplash.com/photo-1552053831-71594a27632d",
    "https://images.unsplash.com/photo-1548199973-03cce0bbc87b",
    "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba",
    "https://images.unsplash.com/photo-1583511655826-05700442b31b",
    "https://images.unsplash.com/photo-1518717758536-85ae29035b6d",
    "https://images.unsplash.com/photo-1537151625747-768eb6cf92b2"
  ]

  puts "Creating users..."

  people.each do |person|
    User.create!(
      username: person.fetch(:username),
      display_name: person.fetch(:display_name),
      email: person.fetch(:email),
      password: "appdev",
      password_confirmation: "appdev",
      bio: person.fetch(:bio),
      website: person.fetch(:website),
      private: person.fetch(:private)
    )
  end

  alice = User.find_by!(username: "alice")
  nick = User.find_by!(username: "nick")
  sarah = User.find_by!(username: "sarah")
  emily = User.find_by!(username: "emily")
  bob = User.find_by!(username: "bob")
  carol = User.find_by!(username: "carol")

  puts "Creating pets..."

  max = alice.pets.create!(
    name: "Max",
    species: "Dog",
    breed: "Golden Retriever",
    gender: "Male",
    size: "Large",
    energy_level: "High",
    temperament: "Friendly",
    vaccinated: true,
    bio: "Max has too much energy and loves carrying toys.",
    image_url: pet_images[0]
  )

  mochi = nick.pets.create!(
    name: "Mochi",
    species: "Cat",
    breed: "Domestic Shorthair",
    gender: "Female",
    size: "Small",
    energy_level: "Low",
    temperament: "Calm",
    vaccinated: true,
    bio: "Mochi prefers watching everyone from a safe distance.",
    image_url: pet_images[2]
  )

  coco = sarah.pets.create!(
    name: "Coco",
    species: "Dog",
    breed: "Corgi",
    gender: "Female",
    size: "Small",
    energy_level: "Medium",
    temperament: "Playful",
    vaccinated: true,
    bio: "Coco acts like she owns every park she enters.",
    image_url: pet_images[1]
  )

  biscuit = emily.pets.create!(
    name: "Biscuit",
    species: "Dog",
    breed: "Poodle",
    gender: "Male",
    size: "Small",
    energy_level: "Medium",
    temperament: "Gentle",
    vaccinated: true,
    bio: "Biscuit likes short walks and polite greetings.",
    image_url: pet_images[3]
  )

  luna = bob.pets.create!(
    name: "Luna",
    species: "Dog",
    breed: "Husky",
    gender: "Female",
    size: "Large",
    energy_level: "High",
    temperament: "Independent",
    vaccinated: true,
    bio: "Luna enjoys early morning walks.",
    image_url: pet_images[4]
  )

  milo = carol.pets.create!(
    name: "Milo",
    species: "Cat",
    breed: "Tabby",
    gender: "Male",
    size: "Small",
    energy_level: "Low",
    temperament: "Curious",
    vaccinated: true,
    bio: "Milo is mostly here to judge the dogs.",
    image_url: pet_images[5]
  )

  puts "Creating owner friendships..."

  [
    [ alice, sarah, "accepted" ],
    [ alice, emily, "accepted" ],
    [ sarah, nick, "accepted" ],
    [ nick, emily, "accepted" ],
    [ bob, carol, "accepted" ],
    [ bob, alice, "pending" ],
    [ carol, sarah, "pending" ]
  ].each do |requester, receiver, status|
    UserFriendship.create!(
      requester: requester,
      receiver: receiver,
      status: status
    )
  end

  puts "Creating pet friendships..."

  [
    [ max, coco, alice, "accepted" ],
    [ max, biscuit, alice, "accepted" ],
    [ coco, biscuit, sarah, "accepted" ],
    [ mochi, milo, nick, "accepted" ],
    [ luna, max, bob, "pending" ],
    [ milo, coco, carol, "pending" ]
  ].each do |requester_pet, receiver_pet, requested_by_user, status|
    PetFriendship.create!(
      requester_pet: requester_pet,
      receiver_pet: receiver_pet,
      requested_by_user: requested_by_user,
      status: status
    )
  end

  puts "Creating posts..."

  posts = []

  posts << alice.posts.create!(
    pet: max,
    body: "Max has way too much energy today. Definitely needs a long walk.",
    image_url: post_images[0],
    created_at: 7.days.ago
  )

  posts << sarah.posts.create!(
    pet: coco,
    body: "Coco met Max today and immediately acted like she owned the park.",
    image_url: post_images[1],
    created_at: 7.days.ago
  )

  posts << nick.posts.create!(
    pet: mochi,
    body: "Mochi is not impressed by any of these dog meetups.",
    image_url: post_images[2],
    created_at: 6.days.ago
  )

  posts << emily.posts.create!(
    pet: biscuit,
    body: "Biscuit made two new friends and then demanded to go home.",
    image_url: post_images[3],
    created_at: 5.days.ago
  )

  posts << bob.posts.create!(
    pet: luna,
    body: "Luna prefers quiet walks before the park gets crowded.",
    image_url: post_images[4],
    created_at: 4.days.ago
  )

  posts << carol.posts.create!(
    pet: milo,
    body: "Milo watched everyone from the window and considered that enough socializing.",
    image_url: post_images[5],
    created_at: 3.days.ago
  )

  puts "Creating comments and likes..."

  posts.each do |post|
    [ alice, nick, sarah, emily ].each do |fan|
      next if fan == post.user

      Like.find_or_create_by!(
        post: post,
        fan: fan
      )
    end
  end

  posts[0].comments.create!(
    author: sarah,
    body: "Okay, I won't."
  )

  posts[1].comments.create!(
    author: emily,
    body: "You can get anything you want at Alice's restaurant."
  )

  posts[2].comments.create!(
    author: carol,
    body: "Mochi understands the assignment."
  )

  posts[3].comments.create!(
    author: alice,
    body: "Biscuit deserves a nap after that."
  )

  posts[4].comments.create!(
    author: nick,
    body: "Early walks are underrated."
  )

  posts[5].comments.create!(
    author: sarah,
    body: "Milo has the right idea."
  )

  puts "Creating walk events..."

  walk_1 = WalkEvent.create!(
    host_user: alice,
    host_pet: max,
    title: "Evening walk at Washington Park",
    note: "Max needs to burn energy. Friendly pets welcome.",
    location_name: "Washington Park",
    latitude: 41.785,
    longitude: -87.619,
    start_time: 2.days.from_now.change(hour: 18, min: 0),
    duration_minutes: 45,
    visibility: "friends_of_either",
    max_participants: 5,
    status: "scheduled"
  )

  walk_2 = WalkEvent.create!(
    host_user: sarah,
    host_pet: coco,
    title: "Short loop near the lake",
    note: "Coco likes social walks but not too long.",
    location_name: "Promontory Point",
    latitude: 41.795,
    longitude: -87.575,
    start_time: 3.days.from_now.change(hour: 10, min: 30),
    duration_minutes: 30,
    visibility: "friends_of_either",
    max_participants: 4,
    status: "scheduled"
  )

  walk_3 = WalkEvent.create!(
    host_user: bob,
    host_pet: luna,
    title: "Quiet morning walk",
    note: "Low-key walk for calm pets.",
    location_name: "Jackson Park",
    latitude: 41.783,
    longitude: -87.580,
    start_time: 4.days.from_now.change(hour: 8, min: 0),
    duration_minutes: 40,
    visibility: "friends_of_either",
    max_participants: 3,
    status: "scheduled"
  )

  puts "Creating walk participants..."

  WalkParticipant.create!(
    walk_event: walk_1,
    user: sarah,
    pet: coco,
    status: "joined",
    joined_at: Time.current
  )

  WalkParticipant.create!(
    walk_event: walk_1,
    user: emily,
    pet: biscuit,
    status: "joined",
    joined_at: Time.current
  )

  WalkParticipant.create!(
    walk_event: walk_2,
    user: alice,
    pet: max,
    status: "joined",
    joined_at: Time.current
  )

  ending = Time.now

  puts "It took #{(ending - starting).to_i} seconds to create sample data."
  puts "There are now #{User.count} users."
  puts "There are now #{Pet.count} pets."
  puts "There are now #{UserFriendship.count} user friendships."
  puts "There are now #{PetFriendship.count} pet friendships."
  puts "There are now #{Post.count} posts."
  puts "There are now #{Like.count} likes."
  puts "There are now #{Comment.count} comments."
  puts "There are now #{WalkEvent.count} walk events."
  puts "There are now #{WalkParticipant.count} walk participants."
end
