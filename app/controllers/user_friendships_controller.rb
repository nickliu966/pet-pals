class UserFriendshipsController < ApplicationController
  before_action :set_user_friendship, only: [ :update, :destroy ]

  def index
    @received_requests = current_user.received_user_friendships.pending
    @sent_requests = current_user.sent_user_friendships.pending
    @friends = (current_user.owner_friends + current_user.friended_by_users).uniq
  end

  def create
    receiver = User.find(user_friendship_params.fetch(:receiver_id))

    if receiver == current_user
      redirect_to user_path(current_user.username),
                  alert: "You cannot follow yourself."
      return
    end

    @user_friendship =
      current_user.sent_user_friendships.find_or_initialize_by(
        receiver: receiver,
      )

    @user_friendship.status = if receiver.private?
        "pending"
    else
        "accepted"
    end

    @user_friendship.accepted_at = Time.current if @user_friendship.accepted?

    respond_to do |format|
      if @user_friendship.save
        notice = if @user_friendship.pending?
            "Follow request sent."
        else
            "You are now following #{receiver.username}."
        end

        format.html { redirect_to user_path(receiver.username), notice: notice }
        format.json { render :show, status: :created, location: @user_friendship }
      else
        format.html { redirect_to user_path(receiver.username), alert: @user_friendship.errors.full_messages.to_sentence }
        format.json { render json: @user_friendship.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! @user_friendship

    if user_friendship_params[:status] == "accepted"
      @user_friendship.accepted_at = Time.current
    end

    respond_to do |format|
      if @user_friendship.update(user_friendship_params)
        notice = if @user_friendship.accepted?
            "Follow request accepted."
        elsif @user_friendship.declined?
            "Follow request declined."
        else
            "Follow request updated."
        end

        format.html do
          redirect_back fallback_location: user_friendships_path,
                        notice: notice
        end

        format.json { render :show, status: :ok, location: @user_friendship }
        format.turbo_stream
      else
        format.html do
          redirect_back fallback_location: user_friendships_path,
                        alert: @user_friendship.errors.full_messages.to_sentence
        end

        format.json { render json: @user_friendship.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! @user_friendship

    receiver = @user_friendship.receiver
    requester = @user_friendship.requester

    notice = if @user_friendship.pending?
        "Follow request cancelled."
    elsif requester == current_user
        "You unfollowed #{receiver.username}."
    else
        "Follower removed."
    end

    @user_friendship.destroy!

    respond_to do |format|
      format.html do
        redirect_back fallback_location: user_path(receiver.username),
                      notice: notice
      end

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
