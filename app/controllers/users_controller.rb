class UsersController < ApplicationController
  before_action :set_user, only: [ :show, :posts, :pets, :friends ]

  def show
  end

  def posts
    @posts = @user.posts.order(created_at: :desc)
  end

  def pets
    @pets = @user.pets.order(created_at: :desc)
  end

  def friends
    @friends = (@user.owner_friends + @user.friended_by_users).uniq
  end

  private

  def set_user
    @user = User.find_by!(username: params.fetch(:username))
  end
end
