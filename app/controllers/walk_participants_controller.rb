class WalkParticipantsController < ApplicationController
  before_action :set_walk_participant, only: [ :update, :destroy ]

  def create
    walk_event = WalkEvent.find(walk_participant_params.fetch(:walk_event_id))
    pet = current_user.pets.find(walk_participant_params.fetch(:pet_id))

    @walk_participant = WalkParticipant.new(walk_participant_params)
    @walk_participant.walk_event = walk_event
    @walk_participant.user = current_user
    @walk_participant.pet = pet
    @walk_participant.status = "joined"
    @walk_participant.joined_at = Time.current

    respond_to do |format|
      if @walk_participant.save
        format.html { redirect_to walk_event_path(walk_event), notice: "You joined this walk." }
        format.json { render :show, status: :created, location: @walk_participant }
      else
        format.html { redirect_to walk_event_path(walk_event), alert: @walk_participant.errors.full_messages.to_sentence }
        format.json { render json: @walk_participant.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @walk_participant.update(walk_participant_update_params)
        format.html { redirect_to walk_event_path(@walk_participant.walk_event), notice: "Walk participation was successfully updated." }
        format.json { render :show, status: :ok, location: @walk_participant }
      else
        format.html { redirect_to walk_event_path(@walk_participant.walk_event), alert: @walk_participant.errors.full_messages.to_sentence }
        format.json { render json: @walk_participant.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @walk_participant.destroy!

    respond_to do |format|
      format.html { redirect_back fallback_location: root_url, notice: "Walk participation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_walk_participant
    @walk_participant = WalkParticipant.find(params.expect(:id))
  end

  def walk_participant_params
    params.expect(walk_participant: [ :walk_event_id, :pet_id ])
  end

  def walk_participant_update_params
    params.expect(walk_participant: [ :status ])
  end
end
