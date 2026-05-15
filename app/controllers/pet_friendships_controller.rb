class PetFriendshipsController < ApplicationController
  before_action :set_pet_friendship, only: %i[ show edit update destroy ]

  # GET /pet_friendships or /pet_friendships.json
  def index
    @pet_friendships = PetFriendship.all
  end

  # GET /pet_friendships/1 or /pet_friendships/1.json
  def show
  end

  # GET /pet_friendships/new
  def new
    @pet_friendship = PetFriendship.new
  end

  # GET /pet_friendships/1/edit
  def edit
  end

  # POST /pet_friendships or /pet_friendships.json
  def create
    @pet_friendship = PetFriendship.new(pet_friendship_params)

    respond_to do |format|
      if @pet_friendship.save
        format.html { redirect_to @pet_friendship, notice: "Pet friendship was successfully created." }
        format.json { render :show, status: :created, location: @pet_friendship }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pet_friendship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pet_friendships/1 or /pet_friendships/1.json
  def update
    respond_to do |format|
      if @pet_friendship.update(pet_friendship_params)
        format.html { redirect_to @pet_friendship, notice: "Pet friendship was successfully updated." }
        format.json { render :show, status: :ok, location: @pet_friendship }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pet_friendship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pet_friendships/1 or /pet_friendships/1.json
  def destroy
    @pet_friendship.destroy!

    respond_to do |format|
      format.html { redirect_to pet_friendships_path, status: :see_other, notice: "Pet friendship was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pet_friendship
      @pet_friendship = PetFriendship.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def pet_friendship_params
      params.expect(pet_friendship: [ :requester_pet_id, :receiver_pet_id, :requested_by_user_id, :status, :accepted_at ])
    end
end
