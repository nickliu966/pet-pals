class WalkEventsController < ApplicationController
  before_action :set_walk_event, only: %i[ show edit update destroy ]

  # GET /walk_events or /walk_events.json
  def index
    @walk_events = WalkEvent.all
  end

  # GET /walk_events/1 or /walk_events/1.json
  def show
  end

  # GET /walk_events/new
  def new
    @walk_event = WalkEvent.new
  end

  # GET /walk_events/1/edit
  def edit
  end

  # POST /walk_events or /walk_events.json
  def create
    @walk_event = WalkEvent.new(walk_event_params)

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

  # PATCH/PUT /walk_events/1 or /walk_events/1.json
  def update
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

  # DELETE /walk_events/1 or /walk_events/1.json
  def destroy
    @walk_event.destroy!

    respond_to do |format|
      format.html { redirect_to walk_events_path, status: :see_other, notice: "Walk event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_walk_event
      @walk_event = WalkEvent.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def walk_event_params
      params.expect(walk_event: [ :host_user_id, :host_pet_id, :title, :note, :location_name, :latitude, :longitude, :start_time, :duration_minutes, :visibility, :max_participants, :status ])
    end
end
