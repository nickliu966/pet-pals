require "rails_helper"

RSpec.describe "User follow/friend relationship logic", type: :model do
  before do
    allow_any_instance_of(User).to receive(:set_default_avatar)
  end

  def create_user(username, private_account: false)
    User.create!(
      username: username,
      email: "#{username}@example.com",
      password: "password",
      password_confirmation: "password",
      private: private_account,
    )
  end

  def follow(follower, followed, status: "accepted")
    UserFriendship.create!(
      requester: follower,
      receiver: followed,
      status: status,
    )
  end

  describe "one-way follows" do
    let!(:alice) { create_user("alice") }
    let!(:bob) { create_user("bob") }

    before do
      follow(alice, bob)
    end

    it "treats requester as following the receiver" do
      expect(alice.follows?(bob)).to be(true)
    end

    it "does not treat receiver as following requester unless there is a reverse relationship" do
      expect(bob.follows?(alice)).to be(false)
    end

    it "treats receiver as followed by requester" do
      expect(bob.followed_by?(alice)).to be(true)
    end

    it "does not treat one-way follow as friendship" do
      expect(alice.friends_with?(bob)).to be(false)
      expect(bob.friends_with?(alice)).to be(false)
    end

    it "includes followed user in following_users" do
      expect(alice.following_users).to contain_exactly(bob)
    end

    it "includes follower in follower_users" do
      expect(bob.follower_users).to contain_exactly(alice)
    end
  end

  describe "mutual follows" do
    let!(:alice) { create_user("alice") }
    let!(:bob) { create_user("bob") }

    before do
      follow(alice, bob)
      follow(bob, alice)
    end

    it "treats both users as friends" do
      expect(alice.friends_with?(bob)).to be(true)
      expect(bob.friends_with?(alice)).to be(true)
    end

    it "includes the other user in mutual_friends" do
      expect(alice.mutual_friends).to contain_exactly(bob)
      expect(bob.mutual_friends).to contain_exactly(alice)
    end

    it "does not include self in mutual_friends" do
      expect(alice.mutual_friends).not_to include(alice)
      expect(bob.mutual_friends).not_to include(bob)
    end
  end

  describe "pending follow requests" do
    let!(:alice) { create_user("alice") }
    let!(:private_bob) { create_user("bob", private_account: true) }

    before do
      follow(alice, private_bob, status: "pending")
    end

    it "knows when current user has requested to follow another user" do
      expect(alice.pending_follow_request_to?(private_bob)).to be(true)
    end

    it "knows when another user has requested to follow current user" do
      expect(private_bob.pending_follow_request_from?(alice)).to be(true)
    end

    it "does not count pending requests as active follows" do
      expect(alice.follows?(private_bob)).to be(false)
      expect(private_bob.followed_by?(alice)).to be(false)
    end

    it "does not count pending requests as friendships" do
      expect(alice.friends_with?(private_bob)).to be(false)
      expect(private_bob.friends_with?(alice)).to be(false)
    end
  end

  describe "self-follow protection" do
    let!(:alice) { create_user("alice") }

    it "does not allow a user to follow themselves" do
      relationship =
        UserFriendship.new(
          requester: alice,
          receiver: alice,
          status: "accepted",
        )

      expect(relationship).not_to be_valid
    end

    it "does not report self-follow as follows?" do
      expect(alice.follows?(alice)).to be(false)
    end

    it "does not report self-follow as followed_by?" do
      expect(alice.followed_by?(alice)).to be(false)
    end

    it "does not report self as a friend" do
      expect(alice.friends_with?(alice)).to be(false)
    end

    it "does not include self in followers or following" do
      expect(alice.follower_users).not_to include(alice)
      expect(alice.following_users).not_to include(alice)
    end
  end

  describe "duplicate follows" do
    let!(:alice) { create_user("alice") }
    let!(:bob) { create_user("bob") }

    before do
      follow(alice, bob)
    end

    it "does not allow the same follower to follow the same receiver twice" do
      duplicate =
        UserFriendship.new(
          requester: alice,
          receiver: bob,
          status: "accepted",
        )

      expect(duplicate).not_to be_valid
    end

    it "does allow the reverse direction because that represents follow back" do
      reverse =
        UserFriendship.new(
          requester: bob,
          receiver: alice,
          status: "accepted",
        )

      expect(reverse).to be_valid
    end
  end
end
