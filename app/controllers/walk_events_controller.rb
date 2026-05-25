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
    host_pet = current_user.pets.find(walk_event_params.fetch(:host_pet_id))

    @walk_event = WalkEvent.new(walk_event_params)
    @walk_event.host_user = current_user
    @walk_event.host_pet = host_pet
    @walk_event.status = "scheduled"

    respond_to do |format|
      if @walk_event.save
        format.html { redirect_to @walk_event, notice: "Walk event was successfully created." }
        format.json { render :show, status: :created, location: @walk_event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @walk_event.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! @walk_event

    if walk_event_params[:host_pet_id].present?
      @walk_event.host_pet = current_user.pets.find(walk_event_params.fetch(:host_pet_id))
    end

    respond_to do |format|
      if @walk_event.update(walk_event_params)
        format.html { redirect_to @walk_event, notice: "Walk event was successfully updated." }
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
