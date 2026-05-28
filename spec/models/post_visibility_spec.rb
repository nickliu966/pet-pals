require "rails_helper"

RSpec.describe Post, type: :model do
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

  def create_post(owner, visibility:, pet: nil, body: nil, latitude: nil, longitude: nil)
    Post.create!(
      user: owner,
      pet: pet,
      visibility: visibility,
      body: body || "#{owner.username} #{visibility} post",
      latitude: latitude,
      longitude: longitude,
    )
  end

  describe ".visible_to" do
    let!(:viewer) { create_user("viewer") }
    let!(:stranger) { create_user("stranger") }
    let!(:one_way_followed_user) { create_user("one_way_followed_user") }
    let!(:one_way_follower_user) { create_user("one_way_follower_user") }
    let!(:mutual_friend) { create_user("mutual_friend") }

    before do
      # viewer follows this user, but they do not follow viewer back
      follow(viewer, one_way_followed_user)

      # this user follows viewer, but viewer does not follow them back
      follow(one_way_follower_user, viewer)

      # mutual friendship
      follow(viewer, mutual_friend)
      follow(mutual_friend, viewer)
    end

    it "includes the viewer's own posts regardless of visibility" do
      own_private_post = create_post(viewer, visibility: "user_friends_only")

      expect(described_class.visible_to(viewer)).to include(own_private_post)
    end

    it "includes everyone posts from any user" do
      public_post = create_post(stranger, visibility: "everyone")

      expect(described_class.visible_to(viewer)).to include(public_post)
    end

    it "excludes user_friends_only posts from strangers" do
      private_post = create_post(stranger, visibility: "user_friends_only")

      expect(described_class.visible_to(viewer)).not_to include(private_post)
    end

    it "excludes user_friends_only posts from one-way followed users" do
      post = create_post(one_way_followed_user, visibility: "user_friends_only")

      expect(viewer.follows?(one_way_followed_user)).to be(true)
      expect(viewer.friends_with?(one_way_followed_user)).to be(false)
      expect(described_class.visible_to(viewer)).not_to include(post)
    end

    it "excludes user_friends_only posts from one-way followers" do
      post = create_post(one_way_follower_user, visibility: "user_friends_only")

      expect(one_way_follower_user.follows?(viewer)).to be(true)
      expect(viewer.friends_with?(one_way_follower_user)).to be(false)
      expect(described_class.visible_to(viewer)).not_to include(post)
    end

    it "includes user_friends_only posts from mutual friends" do
      friend_post = create_post(mutual_friend, visibility: "user_friends_only")

      expect(viewer.friends_with?(mutual_friend)).to be(true)
      expect(described_class.visible_to(viewer)).to include(friend_post)
    end

    it "includes friends_of_either posts from mutual user friends" do
      friend_post = create_post(mutual_friend, visibility: "friends_of_either")

      expect(viewer.friends_with?(mutual_friend)).to be(true)
      expect(described_class.visible_to(viewer)).to include(friend_post)
    end

    it "excludes friends_of_either posts when there is only a one-way user follow and no pet friendship" do
      post = create_post(one_way_followed_user, visibility: "friends_of_either")

      expect(viewer.friends_with?(one_way_followed_user)).to be(false)
      expect(described_class.visible_to(viewer)).not_to include(post)
    end
  end

  describe ".visible_to with pet friendship visibility" do
    let!(:viewer) { create_user("viewer") }
    let!(:pet_owner) { create_user("pet_owner") }
    let!(:stranger) { create_user("stranger") }

    let!(:viewer_pet) { create_pet(viewer, "Viewer Dog") }
    let!(:friend_pet) { create_pet(pet_owner, "Friend Dog") }
    let!(:stranger_pet) { create_pet(stranger, "Stranger Dog") }

    before do
      pet_friend(viewer_pet, friend_pet, requested_by_user: viewer)
    end

    it "includes pet_friends_only posts attached to accepted pet friends" do
      post = create_post(pet_owner, visibility: "pet_friends_only", pet: friend_pet)

      expect(described_class.visible_to(viewer)).to include(post)
    end

    it "includes friends_of_either posts attached to accepted pet friends" do
      post = create_post(pet_owner, visibility: "friends_of_either", pet: friend_pet)

      expect(described_class.visible_to(viewer)).to include(post)
    end

    it "excludes pet_friends_only posts from non-friend pets" do
      post = create_post(stranger, visibility: "pet_friends_only", pet: stranger_pet)

      expect(described_class.visible_to(viewer)).not_to include(post)
    end

    it "does not treat pending pet friendships as visibility permission" do
      pending_pet = create_pet(stranger, "Pending Dog")
      pet_friend(viewer_pet, pending_pet, requested_by_user: viewer, status: "pending")

      post = create_post(stranger, visibility: "pet_friends_only", pet: pending_pet)

      expect(described_class.visible_to(viewer)).not_to include(post)
    end
  end

  describe ".visible_to combined with nearby filtering" do
    let!(:viewer) { create_user("viewer") }
    let!(:stranger) { create_user("stranger") }

    it "keeps all visible posts when radius is blank" do
      located_post =
        create_post(
          stranger,
          visibility: "everyone",
          latitude: 41.80,
          longitude: -87.60,
        )

      unlocated_post =
        create_post(
          stranger,
          visibility: "everyone",
          latitude: nil,
          longitude: nil,
        )

      result =
        described_class
          .visible_to(viewer)
          .near_coordinates(41.80, -87.60, nil)

      expect(result).to include(located_post)
      expect(result).to include(unlocated_post)
    end

    it "includes visible posts inside the selected radius" do
      nearby_post =
        create_post(
          stranger,
          visibility: "everyone",
          latitude: 41.80,
          longitude: -87.60,
        )

      result =
        described_class
          .visible_to(viewer)
          .near_coordinates(41.80, -87.60, 5)

      expect(result).to include(nearby_post)
    end

    it "excludes visible posts outside the selected radius" do
      far_post =
        create_post(
          stranger,
          visibility: "everyone",
          latitude: 42.80,
          longitude: -88.60,
        )

      result =
        described_class
          .visible_to(viewer)
          .near_coordinates(41.80, -87.60, 5)

      expect(result).not_to include(far_post)
    end

    it "excludes posts without coordinates when radius is selected" do
      unlocated_post =
        create_post(
          stranger,
          visibility: "everyone",
          latitude: nil,
          longitude: nil,
        )

      result =
        described_class
          .visible_to(viewer)
          .near_coordinates(41.80, -87.60, 5)

      expect(result).not_to include(unlocated_post)
    end

    it "does not make invisible posts visible just because they are nearby" do
      private_nearby_post =
        create_post(
          stranger,
          visibility: "user_friends_only",
          latitude: 41.80,
          longitude: -87.60,
        )

      result =
        described_class
          .visible_to(viewer)
          .near_coordinates(41.80, -87.60, 5)

      expect(result).not_to include(private_nearby_post)
    end
  end
end
