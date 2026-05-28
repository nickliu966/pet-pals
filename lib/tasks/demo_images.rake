# lib/tasks/demo_images.rake

namespace :demo_images do
  desc "Attach local demo images and create richer visual demo posts"
  task attach: :environment do
    base_dir = Rails.root.join("db", "demo_images")

    resolve_image_path = lambda do |relative_path|
      requested_path = base_dir.join(relative_path)
      return requested_path if requested_path.exist?

      stem = requested_path.sub_ext("").to_s

      match = Dir.glob("#{stem}.{jpg,jpeg,png,webp}").first
      match.present? ? Pathname.new(match) : requested_path
    end

    unless base_dir.exist?
      puts "Missing #{base_dir}. Create db/demo_images first."
      next
    end

    content_type_for = lambda do |path|
      case path.extname.downcase
      when ".png"
        "image/png"
      when ".webp"
        "image/webp"
      else
        "image/jpeg"
      end
    end

    attach_one = lambda do |record, attachment_name, relative_path|
      next if record.nil?

      path = resolve_image_path.call(relative_path)

      unless path.exist?
        puts "Missing image: #{path}"
        next
      end

      attachment = record.public_send(attachment_name)
      attachment.purge if attachment.attached?

      attachment.attach(
        io: File.open(path, "rb"),
        filename: path.basename.to_s,
        content_type: content_type_for.call(path),
      )

      puts "Attached #{relative_path} to #{record.class}##{record.id}.#{attachment_name}"
    end

    attach_many = lambda do |record, attachment_name, relative_paths|
      next if record.nil?

      attachment = record.public_send(attachment_name)
      attachment.purge if attachment.attached?

      relative_paths.each do |relative_path|
        path = resolve_image_path.call(relative_path)

        unless path.exist?
          puts "Missing image: #{path}"
          next
        end

        attachment.attach(
          io: File.open(path, "rb"),
          filename: path.basename.to_s,
          content_type: content_type_for.call(path),
        )

        puts "Attached #{relative_path} to #{record.class}##{record.id}.#{attachment_name}"
      end
    end

    users =
      User
        .where(username: %w[alice nick sarah emily bob carol])
        .index_by(&:username)

    pets =
      Pet
        .where(name: %w[Max Mochi Coco Biscuit Luna Milo])
        .index_by(&:name)

    puts "Attaching user avatars..."

    {
      "alice" => "avatars/alice_avatar.jpg",
      "nick" => "avatars/nick_avatar.jpg",
      "sarah" => "avatars/sarah_avatar.jpg",
      "emily" => "avatars/emily_avatar.jpg",
      "bob" => "avatars/bob_avatar.jpg",
      "carol" => "avatars/carol_avatar.jpg",
    }.each do |username, image_path|
      attach_one.call(users[username], :avatar_image, image_path)
    end

    puts "Attaching profile banners..."

    {
      "alice" => "banners/alice_banner.jpg",
      "nick" => "banners/nick_banner.jpg",
      "sarah" => "banners/sarah_banner.jpg",
      "emily" => "banners/emily_banner.jpg",
      "bob" => "banners/bob_banner.jpg",
      "carol" => "banners/carol_banner.jpg",
    }.each do |username, image_path|
      attach_one.call(users[username], :profile_banner, image_path)
    end

    puts "Attaching pet images..."

    {
      "Max" => "pets/max_golden.jpg",
      "Mochi" => "pets/mochi_cat.jpg",
      "Coco" => "pets/coco_corgi.jpg",
      "Biscuit" => "pets/biscuit_poodle.jpg",
      "Luna" => "pets/luna_husky.jpg",
      "Milo" => "pets/milo_tabby.jpg",
    }.each do |pet_name, image_path|
      attach_one.call(pets[pet_name], :image, image_path)
    end

    puts "Creating richer visual demo posts..."

    demo_posts = [
      {
        username: "alice",
        pet_name: "Max",
        body: "Max found the tennis ball before I even finished my coffee.",
        visibility: "everyone",
        location_name: "Washington Park",
        latitude: 41.785,
        longitude: -87.619,
        created_at: 2.hours.ago,
        images: [
          "posts/max_fetch_ball.jpg",
        ],
      },
      {
        username: "alice",
        pet_name: "Max",
        body: "Park picnic somehow turned into an unofficial dog meetup.",
        visibility: "everyone",
        location_name: "Washington Park",
        latitude: 41.785,
        longitude: -87.619,
        created_at: 5.hours.ago,
        images: [
          "posts/dogs_picnic_park.jpg",
        ],
      },
      {
        username: "sarah",
        pet_name: "Coco",
        body: "Coco believes every sunset walk is actually her public appearance.",
        visibility: "everyone",
        location_name: "Promontory Point",
        latitude: 41.795,
        longitude: -87.575,
        created_at: 1.day.ago,
        images: [
          "posts/coco_sunset_walk.jpg",
        ],
      },
      {
        username: "sarah",
        pet_name: "Coco",
        body: "Coco met Max and immediately started acting like the host.",
        visibility: "friends_of_either",
        location_name: "Washington Park",
        latitude: 41.785,
        longitude: -87.619,
        created_at: 2.days.ago,
        images: [
          "posts/coco_meets_dog.jpg",
        ],
      },
      {
        username: "nick",
        pet_name: "Mochi",
        body: "Mochi watched the birds for twenty minutes and still looked unimpressed.",
        visibility: "everyone",
        location_name: "Hyde Park",
        latitude: 41.794,
        longitude: -87.590,
        created_at: 2.days.ago + 2.hours,
        images: [
          "posts/mochi_window.jpg",
        ],
      },
      {
        username: "emily",
        pet_name: "Biscuit",
        body: "Biscuit made two tiny friends and then decided his social battery was gone.",
        visibility: "everyone",
        location_name: "Nichols Park",
        latitude: 41.790,
        longitude: -87.599,
        created_at: 3.days.ago,
        images: [
          "posts/biscuit_small_dog_friends.jpg",
        ],
      },
      {
        username: "bob",
        pet_name: "Luna",
        body: "Luna still thinks early morning is the only acceptable walk time.",
        visibility: "friends_of_either",
        location_name: "Jackson Park",
        latitude: 41.783,
        longitude: -87.580,
        created_at: 3.days.ago + 3.hours,
        images: [
          "posts/luna_morning_walk.jpg",
        ],
      },
      {
        username: "carol",
        pet_name: "Milo",
        body: "Milo participated in the neighborhood pet scene from a safe indoor distance.",
        visibility: "friends_of_either",
        location_name: "Hyde Park",
        latitude: 41.794,
        longitude: -87.590,
        created_at: 4.days.ago,
        images: [
          "posts/milo_watching_window.jpg",
        ],
      },
      {
        username: "nick",
        pet_name: nil,
        body: "The ducks near the pond were the main characters this morning.",
        visibility: "everyone",
        location_name: "Jackson Park",
        latitude: 41.783,
        longitude: -87.580,
        created_at: 4.days.ago + 4.hours,
        images: [
          "posts/ducks_pond.jpg",
        ],
      },
      {
        username: "alice",
        pet_name: "Max",
        body: "We waited very politely for the geese to finish their crossing.",
        visibility: "everyone",
        location_name: "Washington Park",
        latitude: 41.785,
        longitude: -87.619,
        created_at: 5.days.ago,
        images: [
          "posts/geese_crossing_path.jpg",
        ],
      },
      {
        username: "carol",
        pet_name: "Milo",
        body: "Neighborhood cat spotted supervising the block again.",
        visibility: "everyone",
        location_name: "Hyde Park",
        latitude: 41.794,
        longitude: -87.590,
        created_at: 5.days.ago + 5.hours,
        images: [
          "posts/cat_on_fence.jpg",
        ],
      },
      {
        username: "emily",
        pet_name: nil,
        body: "Tiny bird, very serious bench energy.",
        visibility: "everyone",
        location_name: "Nichols Park",
        latitude: 41.790,
        longitude: -87.599,
        created_at: 6.days.ago,
        images: [
          "posts/bird_near_bench.jpg",
        ],
      },
    ]

    demo_bodies = demo_posts.map { |post_attrs| post_attrs.fetch(:body) }
    Post.where(body: demo_bodies).destroy_all

    created_posts = []

    demo_posts.each do |post_attrs|
      user = users.fetch(post_attrs.fetch(:username))
      pet_name = post_attrs[:pet_name]
      pet = pet_name.present? ? pets[pet_name] : nil

      post = user.posts.create!(
        pet: pet,
        body: post_attrs.fetch(:body),
        visibility: post_attrs.fetch(:visibility),
        location_name: post_attrs.fetch(:location_name),
        latitude: post_attrs.fetch(:latitude),
        longitude: post_attrs.fetch(:longitude),
        created_at: post_attrs.fetch(:created_at),
      )

      attach_many.call(post, :images, post_attrs.fetch(:images))

      created_posts << post
    end

    puts "Creating likes and comments for visual demo posts..."

    created_posts.each do |post|
      users.values.compact.each do |fan|
        next if fan == post.user

        Like.find_or_create_by!(
          post: post,
          fan: fan,
        )
      end
    end

    comment_templates = [
      ["sarah", "This feels like peak park energy."],
      ["nick", "The geese own that path now."],
      ["alice", "Coco looks extremely proud of herself."],
      ["emily", "Biscuit would like the quiet version of this meetup."],
      ["carol", "Milo approves from a safe distance."],
      ["bob", "Early walks are still undefeated."],
    ]

    created_posts.each_with_index do |post, index|
      username, body = comment_templates[index % comment_templates.length]
      author = users[username]

      next if author.nil? || author == post.user

      post.comments.create!(
        author: author,
        body: body,
      )
    end

    puts "Demo images attached."
  end
end

desc "Fill sample data and attach local demo images"
task sample_data_with_images: :environment do
  Rake::Task["sample_data"].invoke
  Rake::Task["demo_images:attach"].invoke
end
