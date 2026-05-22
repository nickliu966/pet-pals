class UserFriendshipsController < ApplicationController
  before_action :set_user_friendship, only: [ :update, :destroy ]

  def index
    @received_requests = current_user.received_user_friendships.pending
    @sent_requests = current_user.sent_user_friendships.pending
    @friends = (current_user.owner_friends + current_user.friended_by_users).uniq
  end

  def create
    receiver = User.find(user_friendship_params.fetch(:receiver_id))

    @user_friendship = UserFriendship.new(user_friendship_params)
    @user_friendship.requester = current_user
    @user_friendship.receiver = receiver
    @user_friendship.status = "pending"

    respond_to do |format|
      if @user_friendship.save
        format.html { redirect_to user_path(receiver.username), notice: "Friend request sent." }
        format.json { render :show, status: :created, location: @user_friendship }
      else
        format.html { redirect_to user_path(receiver.username), alert: @user_friendship.errors.full_messages.to_sentence }
        format.json { render json: @user_friendship.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user_friendship.update(user_friendship_params)
        format.html { redirect_back fallback_location: user_friendships_path, notice: "Friend request was successfully updated." }
        format.json { render :show, status: :ok, location: @user_friendship }
      else
        format.html { redirect_back fallback_location: user_friendships_path, alert: @user_friendship.errors.full_messages.to_sentence }
        format.json { render json: @user_friendship.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user_friendship.destroy!

    respond_to do |format|
      format.html { redirect_back fallback_location: root_url, notice: "Friendship was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_user_friendship
    @user_friendship = UserFriendship.find(params.expect(:id))
  end

  def user_friendship_params
    params.expect(user_friendship: [ :receiver_id, :status ])
  end
end
