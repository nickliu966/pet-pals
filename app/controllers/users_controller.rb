class UsersController < ApplicationController
  before_action :set_user, only: %i[show posts pets friends followers follows update]

  def index
    @users = @q.result(distinct: true).where.not(id: current_user.id)
  end

  def show
    if allowed_to?(:show?, @user)
      @posts = preload_profile_posts(@user.posts.default_order)
      prepare_current_user_likes_for(@posts)
    end
  end

  def update
    unless @user == current_user
      redirect_to user_path(@user.username), alert: "You're not authorized for that."
      return
    end

    if @user.update(user_params)
      redirect_to user_path(@user.username), notice: "Profile was successfully updated."
    else
      redirect_to user_path(@user.username), alert: @user.errors.full_messages.to_sentence
    end
  end

  def posts
    @posts = @user.posts.order(created_at: :desc)
  end

  def pets
    authorize! @user, to: :show?

    @pets = @user.pets.order(created_at: :desc)
  end

  def friends
    authorize! @user, to: :show?

    @friends = @user.mutual_friends.order(:username)
  end

  def followers
    authorize! @user, to: :show?

    @followers = @user.follower_users.order(:username)
  end

  def follows
    authorize! @user, to: :show?

    @follows = @user.following_users.order(:username)
  end

  private

  def preload_profile_posts(posts)
    posts.includes(
      :user,
      :pet,
      :walk_event,
      images_attachments: :blob,
      comments: :author,
    )
  end

  def prepare_current_user_likes_for(posts)
    post_ids = posts.map(&:id)

    @current_user_likes_by_post_id =
      current_user.likes.where(post_id: post_ids).index_by(&:post_id)
  end

  def set_user
    @user = User.find_by!(username: params.fetch(:username))
  end

  def user_params
    params.expect(
      user: [
        :email,
        :username,
        :display_name,
        :bio,
        :city,
        :website,
        :private,
        :avatar_image,
        :profile_banner
      ],
    )
  end
end
