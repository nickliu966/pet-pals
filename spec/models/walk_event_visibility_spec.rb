require "rails_helper"

RSpec.describe WalkEvent, type: :model do
  before do
    allow_any_instance_of(User).to receive(:set_default_avatar)
  end

  def create_user(username)
    User.create!(
      username: username,
      email: "#{username}@example.com",
      password: "password",
      password_confirmation: "password",
    )
  end

  def create_pet(owner, name)
    Pet.create!(
      user: owner,
      name: name,
      species: "Dog",
    )
  end

  def follow(follower, followed, status: "accepted")
    UserFriendship.create!(
      requester: follower,
      receiver: followed,
      status: status,
    )
  end

  def pet_friend(requester_pet, receiver_pet, requested_by_user: requester_pet.user, status: "accepted")
    PetFriendship.create!(
      requester_pet: requester_pet,
      receiver_pet: receiver_pet,
      requested_by_user: requested_by_user,
      status: status,
    )
  end

  def create_walk(host_user, host_pet, visibility:, title: nil, latitude: nil, longitude: nil)
    WalkEvent.create!(
      host_user: host_user,
      host_pet: host_pet,
      title: title || "#{host_user.username} #{visibility} walk",
      location_name: "Test Park",
      latitude: latitude,
      longitude: longitude,
      start_time: 1.day.from_now,
      duration_minutes: 30,
      visibility: visibility,
      max_participants: 5,
      status: "scheduled",
    )
  end

  def join_walk(user, walk_event, pet: nil, status: "joined")
    WalkParticipant.create!(
      user: user,
      pet: pet,
      walk_event: walk_event,
      status: status,
    )
  end

  describe ".visible_to" do
    let!(:viewer) { create_user("viewer") }
    let!(:stranger) { create_user("stranger") }
    let!(:one_way_followed_user) { create_user("one_way_followed_user") }
    let!(:one_way_follower_user) { create_user("one_way_follower_user") }
    let!(:mutual_friend) { create_user("mutual_friend") }

    let!(:viewer_pet) { create_pet(viewer, "Viewer Dog") }
    let!(:stranger_pet) { create_pet(stranger, "Stranger Dog") }
    let!(:one_way_followed_pet) { create_pet(one_way_followed_user, "One Way Followed Dog") }
    let!(:one_way_follower_pet) { create_pet(one_way_follower_user, "One Way Follower Dog") }
    let!(:mutual_friend_pet) { create_pet(mutual_friend, "Mutual Friend Dog") }

    before do
      follow(viewer, one_way_followed_user)
      follow(one_way_follower_user, viewer)

      follow(viewer, mutual_friend)
      follow(mutual_friend, viewer)
    end

    it "includes everyone walks from any user" do
      walk = create_walk(stranger, stranger_pet, visibility: "everyone")

      expect(described_class.visible_to(viewer)).to include(walk)
    end

    it "includes walks hosted by the viewer regardless of visibility" do
      walk = create_walk(viewer, viewer_pet, visibility: "user_friends_only")

      expect(described_class.visible_to(viewer)).to include(walk)
    end

    it "includes walks where the viewer is an active participant" do
      walk = create_walk(stranger, stranger_pet, visibility: "user_friends_only")

      join_walk(viewer, walk, status: "joined")

      expect(described_class.visible_to(viewer)).to include(walk)
    end

    it "includes walks where the viewer is invited" do
      walk = create_walk(stranger, stranger_pet, visibility: "user_friends_only")

      join_walk(viewer, walk, status: "invited")

      expect(described_class.visible_to(viewer)).to include(walk)
    end

    it "excludes walks where the viewer participant record is cancelled" do
      walk = create_walk(stranger, stranger_pet, visibility: "user_friends_only")

      join_walk(viewer, walk, status: "cancelled")

      expect(described_class.visible_to(viewer)).not_to include(walk)
    end

    it "excludes user_friends_only walks from strangers" do
      walk = create_walk(stranger, stranger_pet, visibility: "user_friends_only")

      expect(described_class.visible_to(viewer)).not_to include(walk)
    end

    it "excludes user_friends_only walks from one-way followed users" do
      walk = create_walk(one_way_followed_user, one_way_followed_pet, visibility: "user_friends_only")

      expect(viewer.follows?(one_way_followed_user)).to be(true)
      expect(viewer.friends_with?(one_way_followed_user)).to be(false)
      expect(described_class.visible_to(viewer)).not_to include(walk)
    end

    it "excludes user_friends_only walks from one-way followers" do
      walk = create_walk(one_way_follower_user, one_way_follower_pet, visibility: "user_friends_only")

      expect(one_way_follower_user.follows?(viewer)).to be(true)
      expect(viewer.friends_with?(one_way_follower_user)).to be(false)
      expect(described_class.visible_to(viewer)).not_to include(walk)
    end

    it "includes user_friends_only walks from mutual friends" do
      walk = create_walk(mutual_friend, mutual_friend_pet, visibility: "user_friends_only")

      expect(viewer.friends_with?(mutual_friend)).to be(true)
      expect(described_class.visible_to(viewer)).to include(walk)
    end

    it "includes friends_of_either walks from mutual user friends" do
      walk = create_walk(mutual_friend, mutual_friend_pet, visibility: "friends_of_either")

      expect(described_class.visible_to(viewer)).to include(walk)
    end
  end

  describe ".visible_to with pet-friend visibility" do
    let!(:viewer) { create_user("viewer") }
    let!(:pet_owner) { create_user("pet_owner") }
    let!(:stranger) { create_user("stranger") }

    let!(:viewer_pet) { create_pet(viewer, "Viewer Dog") }
    let!(:friend_pet) { create_pet(pet_owner, "Friend Dog") }
    let!(:stranger_pet) { create_pet(stranger, "Stranger Dog") }

    before do
      pet_friend(viewer_pet, friend_pet, requested_by_user: viewer)
    end

    it "includes pet_friends_only walks hosted with accepted pet friends" do
      walk = create_walk(pet_owner, friend_pet, visibility: "pet_friends_only")

      expect(described_class.visible_to(viewer)).to include(walk)
    end

    it "includes friends_of_either walks hosted with accepted pet friends" do
      walk = create_walk(pet_owner, friend_pet, visibility: "friends_of_either")

      expect(described_class.visible_to(viewer)).to include(walk)
    end

    it "excludes pet_friends_only walks from non-friend pets" do
      walk = create_walk(stranger, stranger_pet, visibility: "pet_friends_only")

      expect(described_class.visible_to(viewer)).not_to include(walk)
    end

    it "does not treat pending pet friendships as pet-friend permission" do
      pending_pet = create_pet(stranger, "Pending Dog")
      pet_friend(viewer_pet, pending_pet, requested_by_user: viewer, status: "pending")

      walk = create_walk(stranger, pending_pet, visibility: "pet_friends_only")

      expect(described_class.visible_to(viewer)).not_to include(walk)
    end
  end

  describe ".visible_to combined with nearby filtering" do
    let!(:viewer) { create_user("viewer") }
    let!(:stranger) { create_user("stranger") }
    let!(:stranger_pet) { create_pet(stranger, "Stranger Dog") }

    it "keeps all visible walks when radius is blank" do
      located_walk =
        create_walk(
          stranger,
          stranger_pet,
          visibility: "everyone",
          latitude: 41.80,
          longitude: -87.60,
        )

      unlocated_walk =
        create_walk(
          stranger,
          stranger_pet,
          visibility: "everyone",
          latitude: nil,
          longitude: nil,
        )

      result =
        described_class
          .visible_to(viewer)
          .near_coordinates(41.80, -87.60, nil)

      expect(result).to include(located_walk)
      expect(result).to include(unlocated_walk)
    end

    it "includes visible walks inside the selected radius" do
      nearby_walk =
        create_walk(
          stranger,
          stranger_pet,
          visibility: "everyone",
          latitude: 41.80,
          longitude: -87.60,
        )

      result =
        described_class
          .visible_to(viewer)
          .near_coordinates(41.80, -87.60, 5)

      expect(result).to include(nearby_walk)
    end

    it "excludes visible walks outside the selected radius" do
      far_walk =
        create_walk(
          stranger,
          stranger_pet,
          visibility: "everyone",
          latitude: 42.80,
          longitude: -88.60,
        )

      result =
        described_class
          .visible_to(viewer)
          .near_coordinates(41.80, -87.60, 5)

      expect(result).not_to include(far_walk)
    end

    it "does not make invisible walks visible just because they are nearby" do
      invisible_nearby_walk =
        create_walk(
          stranger,
          stranger_pet,
          visibility: "user_friends_only",
          latitude: 41.80,
          longitude: -87.60,
        )

      result =
        described_class
          .visible_to(viewer)
          .near_coordinates(41.80, -87.60, 5)

      expect(result).not_to include(invisible_nearby_walk)
    end
  end
end
