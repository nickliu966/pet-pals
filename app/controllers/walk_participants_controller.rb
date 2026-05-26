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

      broadcast_walk_event_participation(walk_event)

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

    broadcast_walk_event_participation(walk_event)

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
    removed_user = @walk_participant.user

    @walk_participant.destroy

    broadcast_walk_event_participation(walk_event, extra_viewers: [removed_user])

    redirect_to walk_event_path(walk_event),
                notice: "Participant was removed."
  end

  def accept
    @walk_participant = WalkParticipant.find(params.fetch(:id))

    if @walk_participant.user == current_user && @walk_participant.joined?
      redirect_to safe_walk_participant_return_to(@walk_participant.walk_event),
                  notice: "You already accepted this invitation."
      return
    end

    authorize! @walk_participant

    walk_event = @walk_participant.walk_event

    @walk_participant.update!(
      status: "joined",
      joined_at: Time.current,
    )

    broadcast_walk_event_participation(walk_event)

    redirect_to safe_walk_participant_return_to(walk_event),
                notice: "You accepted the invitation."
  end

  def decline
    @walk_participant = WalkParticipant.find(params.fetch(:id))

    if @walk_participant.user == current_user && @walk_participant.cancelled?
      redirect_to safe_walk_participant_return_to(@walk_participant.walk_event),
                  notice: "You already declined this invitation."
      return
    end

    authorize! @walk_participant

    walk_event = @walk_participant.walk_event
    viewer = @walk_participant.user

    @walk_participant.update!(status: "cancelled")

    broadcast_walk_event_participation(walk_event, extra_viewers: [viewer])

    redirect_to safe_walk_participant_return_to(walk_event),
                notice: "You declined the invitation."
  end

  private

  def safe_walk_participant_return_to(walk_event)
    return_to = params[:return_to].presence

    if return_to&.start_with?("/")
      return_to
    else
      walk_event_path(walk_event)
    end
  end

  def broadcast_walk_event_participation(walk_event, extra_viewers: [])
    walk_event.reload

    Turbo::StreamsChannel.broadcast_replace_to(
      walk_event,
      target: helpers.dom_id(walk_event, :participant_count),
      partial: "walk_events/participant_count",
      locals: { walk_event: walk_event },
    )

    viewers =
      [
        walk_event.host_user,
        *walk_event.confirmed_participants.includes(:user).map(&:user),
        *extra_viewers,
      ].compact.uniq

    viewers.each do |viewer|
      Turbo::StreamsChannel.broadcast_replace_to(
        participant_list_stream_for(walk_event, viewer),
        target: helpers.dom_id(walk_event, :participant_list),
        partial: "walk_events/participant_list",
        locals: {
          walk_event: walk_event,
          viewer: viewer,
        },
      )

      Turbo::StreamsChannel.broadcast_replace_to(
        join_controls_stream_for(walk_event, viewer),
        target: helpers.dom_id(walk_event, :join_controls),
        partial: "walk_events/join_controls",
        locals: {
          walk_event: walk_event,
          viewer: viewer,
          return_to: nil,
        },
      )
    end
  end

  def participant_list_stream_for(walk_event, viewer)
    "walk_event_#{walk_event.id}_participant_list_user_#{viewer.id}"
  end

  def join_controls_stream_for(walk_event, viewer)
    "walk_event_#{walk_event.id}_join_controls_user_#{viewer.id}"
  end

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
