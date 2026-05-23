class UsersController < ApplicationController
  before_action :set_user, only: %i[show posts pets friends followers follows]

  def index
    @users = @q.result(distinct: true).where.not(id: current_user.id)
  end

  def show
  end

  def posts
    @posts = @user.posts.order(created_at: :desc)
  end

  def pets
    @pets = @user.pets.order(created_at: :desc)
  end

  def friends
    @followers = @user.friended_by_users
    @following = @user.owner_friends
  end

  def followers
    @followers = @user.friended_by_users
  end

  def follows
    @follows = @user.owner_friends
  end

  private

  def set_user
    @user = User.find_by!(username: params.fetch(:username))
  end
end
