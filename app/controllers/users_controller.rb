class UsersController < ApplicationController
  before_action :set_user, only: %i[show posts pets friends followers follows update]

  def index
    @users = @q.result(distinct: true).where.not(id: current_user.id)
  end

  def show
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
    @followers = @user.friended_by_users
    @following = @user.owner_friends
  end

  def followers
    authorize! @user, to: :view_private_content?

    @followers = @user.friended_by_users
  end

  def follows
    authorize! @user, to: :view_private_content?

    @follows = @user.owner_friends
  end

  private

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
        :profile_banner,
      ],
    )
  end
end
