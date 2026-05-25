class WalkEventsController < ApplicationController
  before_action :set_walk_event, only: [:show, :edit, :update, :destroy]

  def index
    @walk_events = WalkEvent.order(start_time: :asc)
  end

  def show
  end

  def new
    @walk_event = WalkEvent.new
  end

  def edit
    authorize! @walk_event
  end

  def create
    @walk_event = current_user.hosted_walk_events.build(walk_event_params)
    @walk_event.status = "scheduled"

    respond_to do |format|
      if @walk_event.save
        # Host pets are stored through walk_participants, not directly on walk_events.
        sync_host_pets

        return_to = params[:return_to].presence
        return_to = walk_event_path(@walk_event) unless return_to&.start_with?("/")

        format.html { redirect_to return_to, notice: "Walk event was successfully created." }
        format.json { render :show, status: :created, location: @walk_event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @walk_event.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! @walk_event

    respond_to do |format|
      if @walk_event.update(walk_event_params)
        sync_host_pets

        return_to = params[:return_to].presence
        return_to = walk_event_path(@walk_event) unless return_to&.start_with?("/")

        format.html { redirect_to return_to, notice: "Walk event was successfully updated." }
        format.json { render :show, status: :ok, location: @walk_event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @walk_event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! @walk_event

    @walk_event.destroy!

    respond_to do |format|
      format.html { redirect_back fallback_location: root_url, notice: "Walk event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def mine
    walk_event_ids =
      current_user.hosted_walk_events.pluck(:id) +
      current_user.joined_walk_events.pluck(:id)

    @walk_events = WalkEvent
      .where(id: walk_event_ids.uniq)
      .order(start_time: :asc)
  end

  private

  def set_walk_event
    @walk_event = WalkEvent.find(params.expect(:id))
  end

  # Get selected host pet ids from the form.
  def host_pet_ids
    Array(params.dig(:walk_event, :host_pet_ids)).reject(&:blank?)
  end

  # Keep the host's walk participants in sync with the selected pets.
  # Host pets are not stored directly on the walk event.
  # They are stored as walk_participant records.
  # So when the host edits the checkboxes, we need to update those related records.
  def sync_host_pets
    host_user = @walk_event.host_user
    selected_pets = host_user.pets.where(id: host_pet_ids)

    @walk_event.walk_participants
               .where(user: host_user)
               .where.not(pet_id: selected_pets.pluck(:id))
               .destroy_all

    selected_pets.each do |pet|
      @walk_event.walk_participants.find_or_create_by!(
        user: host_user,
        pet: pet,
      )
    end
  end

  def walk_event_params
    params.expect(walk_event: [
                    :title,
                    :note,
                    :location_name,
                    :latitude,
                    :longitude,
                    :google_place_id,
                    :start_time,
                    :duration_minutes,
                    :visibility,
                    :max_participants,
                    :status,
                  ])
  end
end
