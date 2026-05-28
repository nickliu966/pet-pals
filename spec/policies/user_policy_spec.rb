require "rails_helper"

RSpec.describe UserPolicy, type: :model do
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

  def policy_for(viewer, record)
    described_class.new(record, user: viewer)
  end

  describe "#show?" do
    let!(:viewer) { create_user("viewer") }
    let!(:public_user) { create_user("public_user", private_account: false) }
    let!(:private_user) { create_user("private_user", private_account: true) }

    it "allows a user to view their own profile, even if private" do
      private_viewer = create_user("private_viewer", private_account: true)

      expect(policy_for(private_viewer, private_viewer).show?).to be(true)
    end

    it "allows anyone logged in to view a public profile" do
      expect(policy_for(viewer, public_user).show?).to be(true)
    end

    it "does not allow a stranger to view a private profile" do
      expect(policy_for(viewer, private_user).show?).to be(false)
    end

    it "does not allow a one-way follower to view a private profile" do
      follow(viewer, private_user)

      expect(viewer.follows?(private_user)).to be(true)
      expect(private_user.follows?(viewer)).to be(false)
      expect(policy_for(viewer, private_user).show?).to be(false)
    end

    it "does not allow a one-way follower in the opposite direction to view a private profile" do
      follow(private_user, viewer)

      expect(private_user.follows?(viewer)).to be(true)
      expect(viewer.follows?(private_user)).to be(false)
      expect(policy_for(viewer, private_user).show?).to be(false)
    end

    it "allows a mutual friend to view a private profile" do
      follow(viewer, private_user)
      follow(private_user, viewer)

      expect(viewer.friends_with?(private_user)).to be(true)
      expect(policy_for(viewer, private_user).show?).to be(true)
    end

    it "does not treat pending follow requests as permission to view private profiles" do
      follow(viewer, private_user, status: "pending")

      expect(viewer.pending_follow_request_to?(private_user)).to be(true)
      expect(policy_for(viewer, private_user).show?).to be(false)
    end
  end

  describe "#view_private_content?" do
    let!(:viewer) { create_user("viewer") }
    let!(:private_user) { create_user("private_user", private_account: true) }

    it "uses the same logic as show?" do
      expect(policy_for(viewer, private_user).view_private_content?).to eq(
        policy_for(viewer, private_user).show?
      )
    end
  end
end
