class WalkParticipantsController < ApplicationController
  before_action :set_walk_participant, only: [:update, :destroy]

  def create
    walk_event = WalkEvent.find(walk_participant_params.fetch(:walk_event_id))

    invited_participant =
      walk_event.walk_participants.find_by(
        user: current_user,
        status: "invited",
      )

    if invited_participant.present?
      invited_participant.update!(
        status: "joined",
        joined_at: Time.current,
      )

      redirect_to walk_event_path(walk_event),
                  notice: "You joined this walk."
      return
    end

    pet_ids = Array(walk_participant_params[:pet_ids]).reject(&:blank?)
    pets = current_user.pets.where(id: pet_ids)

    existing_participants = walk_event.walk_participants.where(user: current_user)

    if pets.any?
      # If user previously joined without a pet, remove that placeholder row.
      existing_participants.where(pet_id: nil).destroy_all

      pets.each do |pet|
        walk_event.walk_participants.find_or_create_by!(
          user: current_user,
          pet: pet,
        )
      end

      notice = "You joined this walk."
    elsif existing_participants.none?
      # Only create a no-pet participant if user has not joined at all.
      walk_event.walk_participants.create!(
        user: current_user,
        pet: nil,
      )

      notice = "You joined this walk."
    else
      # User already joined, and did not select any new pets.
      notice = "You are already joining this walk."
    end

    redirect_to walk_event_path(walk_event, return_to: params[:return_to]),
                notice: notice
  end

  def update
    authorize! @walk_participant

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
    @walk_participant = WalkParticipant.find(params.fetch(:id))
    authorize! @walk_participant

    walk_event = @walk_participant.walk_event
    @walk_participant.destroy

    redirect_to walk_event_path(walk_event),
                notice: "Participant was removed."
  end

  def accept
    @walk_participant = WalkParticipant.find(params.fetch(:id))
    authorize! @walk_participant

    @walk_participant.update!(
      status: "joined",
      joined_at: Time.current,
    )

    redirect_to walk_event_path(@walk_participant.walk_event),
                notice: "You accepted the invitation."
  end

  def decline
    @walk_participant = WalkParticipant.find(params.fetch(:id))
    authorize! @walk_participant

    @walk_participant.update!(status: "cancelled")

    redirect_to walk_event_path(@walk_participant.walk_event),
                notice: "You declined the invitation."
  end

  private

  def set_walk_participant
    @walk_participant = WalkParticipant.find(params.expect(:id))
  end

  def walk_participant_params
    params.expect(walk_participant: [:walk_event_id, :pet_id])
  end

  def walk_participant_update_params
    params.expect(walk_participant: [:status])
  end

  def walk_participant_params
    params.expect(
      walk_participant: [
        :walk_event_id,
        pet_ids: [],
      ],
    )
  end
end
