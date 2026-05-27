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

    @posts = preload_post_feed_associations(Post.where(id: post_ids.uniq).default_order)
    prepare_current_user_likes_for(@posts)
  end

  def discover
    posts = Post.everyone

    if nearby_filter?
      posts = posts.near_coordinates(
        params[:latitude],
        params[:longitude],
        nearby_radius_miles,
      )
    end

    @posts = preload_post_feed_associations(posts.default_order)
    prepare_current_user_likes_for(@posts)
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

        return_to = params[:return_to].presence
        return_to = root_path unless return_to&.start_with?("/")

        format.html { redirect_to return_to, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! @post

    @expanded = params[:expanded] == "true"

    permitted_params = post_params

    if visibility_only_update?(permitted_params)
      @expanded = params[:expanded] == "true"
      visibility = permitted_params.fetch(:visibility)

      unless Post.visibilities.key?(visibility)
        respond_to do |format|
          format.html { redirect_to safe_post_return_to, alert: "Invalid visibility." }
          format.turbo_stream { head :unprocessable_entity }
        end

        return
      end

      @post.update_column(:visibility, visibility)

      respond_to do |format|
        format.html do
          redirect_to safe_post_return_to,
                      notice: "Post visibility was successfully updated."
        end

        format.turbo_stream
      end

      return
    end

    @post.assign_attributes(permitted_params)

    if @post.pet_id.present?
      @post.pet = current_user.pets.find(@post.pet_id)
    end

    respond_to do |format|
      if @post.save
        @post.images.attach(uploaded_images) if uploaded_images.any?

        format.html do
          redirect_to safe_post_return_to,
                      notice: "Post was successfully updated."
        end

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
      format.turbo_stream
    end
  end

  private

  def nearby_filter?
    params[:near_me] == "1" &&
      params[:latitude].present? &&
      params[:longitude].present?
  end

  def nearby_radius_miles
    params[:radius_miles].presence
  end

  def preload_post_feed_associations(posts)
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

  def set_post
    @post = Post.find(params.expect(:id))
  end

  def visibility_only_update?(permitted_params)
    permitted_params.keys.map(&:to_s).sort == ["visibility"]
  end

  def safe_post_return_to
    return_to = params[:return_to].presence

    if return_to&.start_with?("/")
      return_to
    else
      post_path(@post)
    end
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
                    :walk_event_id,
                    photos: [],
                  ])
  end

  def uploaded_images
    Array(params.dig(:post, :images)).reject(&:blank?)
  end
end
