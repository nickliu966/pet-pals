class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    post_ids = []

    # 1. Always include my own posts
    post_ids += current_user.posts.pluck(:id)

    # 2. Include owner-friend posts
    owner_friends = (current_user.owner_friends + current_user.friended_by_users).uniq

    post_ids += Post.where(user: owner_friends)
                    .where(visibility: ["everyone", "user_friends_only", "friends_of_either"])
                    .pluck(:id)

    # 3. Include pet-friend posts
    pet_friends = []

    current_user.pets.each do |pet|
      pet_friends += pet.pet_friends
      pet_friends += pet.friended_by_pets
    end

    pet_friends = pet_friends.uniq

    post_ids += Post.where(pet: pet_friends)
                    .where(visibility: ["everyone", "pet_friends_only", "friends_of_either"])
                    .pluck(:id)

    @posts = Post.where(id: post_ids.uniq).default_order
  end

  def discover
    @posts = Post.everyone.default_order
  end

  def show
    authorize! @post
  end

  def new
    @post = current_user.posts.build
  end

  def edit
    authorize! @post
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.pet_id.present?
      @post.pet = current_user.pets.find(@post.pet_id)
    end

    respond_to do |format|
      if @post.save
        @post.images.attach(uploaded_images) if uploaded_images.any?

        format.html { redirect_to root_path, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! @post

    @post.assign_attributes(post_params)

    if @post.pet_id.present?
      @post.pet = current_user.pets.find(@post.pet_id)
    end

    respond_to do |format|
      if @post.save
        @post.images.attach(uploaded_images) if uploaded_images.any?

        return_to = params[:return_to].presence
        return_to = post_path(@post) unless return_to&.start_with?("/")

        format.html { redirect_to return_to, notice: "Post was successfully updated." }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! @post

    @post.destroy!

    respond_to do |format|
      format.html { redirect_back fallback_location: root_url, notice: "Post was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_post
    @post = Post.find(params.expect(:id))
  end

  def post_params
    params.expect(post: [
                    :pet_id,
                    :body,
                    :location_name,
                    :latitude,
                    :longitude,
                    :google_place_id,
                    :visibility,
                  ])
  end

  def uploaded_images
    Array(params.dig(:post, :images)).reject(&:blank?)
  end
end
