class UserFriendshipsController < ApplicationController
  before_action :set_user_friendship, only: %i[ show edit update destroy ]

  # GET /user_friendships or /user_friendships.json
  def index
    @user_friendships = UserFriendship.all
  end

  # GET /user_friendships/1 or /user_friendships/1.json
  def show
  end

  # GET /user_friendships/new
  def new
    @user_friendship = UserFriendship.new
  end

  # GET /user_friendships/1/edit
  def edit
  end

  # POST /user_friendships or /user_friendships.json
  def create
    @user_friendship = UserFriendship.new(user_friendship_params)

    respond_to do |format|
      if @user_friendship.save
        format.html { redirect_to @user_friendship, notice: "User friendship was successfully created." }
        format.json { render :show, status: :created, location: @user_friendship }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user_friendship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_friendships/1 or /user_friendships/1.json
  def update
    respond_to do |format|
      if @user_friendship.update(user_friendship_params)
        format.html { redirect_to @user_friendship, notice: "User friendship was successfully updated." }
        format.json { render :show, status: :ok, location: @user_friendship }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user_friendship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_friendships/1 or /user_friendships/1.json
  def destroy
    @user_friendship.destroy!

    respond_to do |format|
      format.html { redirect_to user_friendships_path, status: :see_other, notice: "User friendship was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_friendship
      @user_friendship = UserFriendship.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def user_friendship_params
      params.expect(user_friendship: [ :requester_id, :receiver_id, :status, :accepted_at ])
    end
end
