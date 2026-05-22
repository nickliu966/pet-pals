class PetFriendshipsController < ApplicationController
  before_action :set_pet_friendship, only: [ :update, :destroy ]

  def index
    user_pet_ids = current_user.pets.select(:id)

    @received_requests = PetFriendship.pending.where(receiver_pet_id: user_pet_ids)
    @sent_requests = PetFriendship.pending.where(requester_pet_id: user_pet_ids)

    @pet_friendships =
      PetFriendship.accepted
                   .where(requester_pet_id: user_pet_ids)
                   .or(PetFriendship.accepted.where(receiver_pet_id: user_pet_ids))
  end

  def create
    requester_pet = current_user.pets.find(pet_friendship_params.fetch(:requester_pet_id))
    receiver_pet = Pet.find(pet_friendship_params.fetch(:receiver_pet_id))

    @pet_friendship = PetFriendship.new(pet_friendship_params)
    @pet_friendship.requester_pet = requester_pet
    @pet_friendship.receiver_pet = receiver_pet
    @pet_friendship.requested_by_user = current_user
    @pet_friendship.status = "pending"

    respond_to do |format|
      if @pet_friendship.save
        format.html { redirect_to pet_path(receiver_pet), notice: "Pet friend request sent." }
        format.json { render :show, status: :created, location: @pet_friendship }
      else
        format.html { redirect_to pet_path(receiver_pet), alert: @pet_friendship.errors.full_messages.to_sentence }
        format.json { render json: @pet_friendship.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @pet_friendship.update(pet_friendship_params)
        format.html { redirect_back fallback_location: pet_friendships_path, notice: "Pet friendship was successfully updated." }
        format.json { render :show, status: :ok, location: @pet_friendship }
      else
        format.html { redirect_back fallback_location: pet_friendships_path, alert: @pet_friendship.errors.full_messages.to_sentence }
        format.json { render json: @pet_friendship.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @pet_friendship.destroy!

    respond_to do |format|
      format.html { redirect_back fallback_location: root_url, notice: "Pet friendship was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_pet_friendship
    @pet_friendship = PetFriendship.find(params.expect(:id))
  end

  def pet_friendship_params
    params.expect(pet_friendship: [ :requester_pet_id, :receiver_pet_id, :status ])
  end
end
