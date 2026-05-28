require "rails_helper"

RSpec.describe "User follow requests", type: :request do
  include Devise::Test::IntegrationHelpers

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
      accepted_at: status == "accepted" ? Time.current : nil,
    )
  end

  describe "POST /user_friendships" do
    let!(:alice) { create_user("alice") }
    let!(:bob) { create_user("bob") }

    before do
      sign_in alice
    end

    it "immediately follows a public user" do
      expect {
        post user_friendships_path,
             params: {
               user_friendship: {
                 receiver_id: bob.id,
               },
             }
      }.to change(UserFriendship, :count).by(1)

      friendship = UserFriendship.last

      expect(friendship.requester).to eq(alice)
      expect(friendship.receiver).to eq(bob)
      expect(friendship.status).to eq("accepted")
      expect(friendship.accepted_at).to be_present

      expect(response).to redirect_to(user_path(bob.username))
      follow_redirect!

      expect(response.body).to include("You are now following bob.")
    end

    it "creates a pending follow request for a private user" do
      private_bob = create_user("private_bob", private_account: true)

      expect {
        post user_friendships_path,
             params: {
               user_friendship: {
                 receiver_id: private_bob.id,
               },
             }
      }.to change(UserFriendship, :count).by(1)

      friendship = UserFriendship.last

      expect(friendship.requester).to eq(alice)
      expect(friendship.receiver).to eq(private_bob)
      expect(friendship.status).to eq("pending")
      expect(friendship.accepted_at).to be_nil

      expect(response).to redirect_to(user_path(private_bob.username))
      follow_redirect!

      expect(response.body).to include("Follow request sent.")
    end

    it "does not allow a user to follow themselves" do
      expect {
        post user_friendships_path,
             params: {
               user_friendship: {
                 receiver_id: alice.id,
               },
             }
      }.not_to change(UserFriendship, :count)

      expect(response).to redirect_to(user_path(alice.username))
      follow_redirect!

      expect(response.body).to include("You cannot follow yourself.")
    end

    it "does not create a duplicate follow record" do
      follow(alice, bob)

      expect {
        post user_friendships_path,
             params: {
               user_friendship: {
                 receiver_id: bob.id,
               },
             }
      }.not_to change(UserFriendship, :count)

      expect(UserFriendship.where(requester: alice, receiver: bob).count).to eq(1)
    end
  end

  describe "PATCH /user_friendships/:id" do
    let!(:requester) { create_user("requester") }
    let!(:receiver) { create_user("receiver", private_account: true) }
    let!(:stranger) { create_user("stranger") }

    let!(:follow_request) do
      follow(requester, receiver, status: "pending")
    end

    it "allows the receiver to accept a follow request" do
      sign_in receiver

      patch user_friendship_path(follow_request),
            params: {
              user_friendship: {
                status: "accepted",
              },
            },
            headers: {
              "HTTP_REFERER" => user_friendships_path,
            }

      expect(response).to redirect_to(user_friendships_path)

      follow_request.reload

      expect(follow_request.status).to eq("accepted")
      expect(follow_request.accepted_at).to be_present
    end

    it "allows the receiver to decline a follow request" do
      sign_in receiver

      patch user_friendship_path(follow_request),
            params: {
              user_friendship: {
                status: "declined",
              },
            },
            headers: {
              "HTTP_REFERER" => user_friendships_path,
            }

      expect(response).to redirect_to(user_friendships_path)

      follow_request.reload

      expect(follow_request.status).to eq("declined")
    end

    it "does not allow the requester to accept their own request" do
      sign_in requester

      patch user_friendship_path(follow_request),
            params: {
              user_friendship: {
                status: "accepted",
              },
            },
            headers: {
              "HTTP_REFERER" => user_friendships_path,
            }

      expect(response).to redirect_to(user_friendships_path)
      expect(flash[:alert]).to eq("You're not authorized for that.")
      expect(follow_request.reload.status).to eq("pending")
    end

    it "does not allow a stranger to accept someone else's request" do
      sign_in stranger

      patch user_friendship_path(follow_request),
            params: {
              user_friendship: {
                status: "accepted",
              },
            },
            headers: {
              "HTTP_REFERER" => user_friendships_path,
            }

      expect(response).to redirect_to(user_friendships_path)
      expect(flash[:alert]).to eq("You're not authorized for that.")
      expect(follow_request.reload.status).to eq("pending")
    end
  end

  describe "DELETE /user_friendships/:id" do
    let!(:alice) { create_user("alice") }
    let!(:bob) { create_user("bob") }
    let!(:stranger) { create_user("stranger") }

    it "allows the requester to unfollow" do
      friendship = follow(alice, bob)

      sign_in alice

      expect {
        delete user_friendship_path(friendship),
               headers: {
                 "HTTP_REFERER" => user_path(bob.username),
               }
      }.to change(UserFriendship, :count).by(-1)

      expect(response).to redirect_to(user_path(bob.username))
    end

    it "allows the requester to cancel a pending request" do
      request = follow(alice, bob, status: "pending")

      sign_in alice

      expect {
        delete user_friendship_path(request),
               headers: {
                 "HTTP_REFERER" => user_path(bob.username),
               }
      }.to change(UserFriendship, :count).by(-1)

      expect(response).to redirect_to(user_path(bob.username))
    end

    it "allows the receiver to remove a follower" do
      friendship = follow(alice, bob)

      sign_in bob

      expect {
        delete user_friendship_path(friendship),
               headers: {
                 "HTTP_REFERER" => followers_path(bob.username),
               }
      }.to change(UserFriendship, :count).by(-1)

      expect(response).to redirect_to(followers_path(bob.username))
    end

    it "does not allow a stranger to destroy another relationship" do
      relationship = follow(alice, bob)

      sign_in stranger

      expect {
        delete user_friendship_path(relationship),
               headers: {
                 "HTTP_REFERER" => user_path(bob.username),
               }
      }.not_to change(UserFriendship, :count)

      expect(response).to redirect_to(user_path(bob.username))
      expect(flash[:alert]).to eq("You're not authorized for that.")
      expect(UserFriendship.exists?(relationship.id)).to be(true)
    end
  end
end
