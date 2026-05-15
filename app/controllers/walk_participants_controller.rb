class WalkParticipantsController < ApplicationController
  before_action :set_walk_participant, only: %i[ show edit update destroy ]

  # GET /walk_participants or /walk_participants.json
  def index
    @walk_participants = WalkParticipant.all
  end

  # GET /walk_participants/1 or /walk_participants/1.json
  def show
  end

  # GET /walk_participants/new
  def new
    @walk_participant = WalkParticipant.new
  end

  # GET /walk_participants/1/edit
  def edit
  end

  # POST /walk_participants or /walk_participants.json
  def create
    @walk_participant = WalkParticipant.new(walk_participant_params)

    respond_to do |format|
      if @walk_participant.save
        format.html { redirect_to @walk_participant, notice: "Walk participant was successfully created." }
        format.json { render :show, status: :created, location: @walk_participant }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @walk_participant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /walk_participants/1 or /walk_participants/1.json
  def update
    respond_to do |format|
      if @walk_participant.update(walk_participant_params)
        format.html { redirect_to @walk_participant, notice: "Walk participant was successfully updated." }
        format.json { render :show, status: :ok, location: @walk_participant }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @walk_participant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /walk_participants/1 or /walk_participants/1.json
  def destroy
    @walk_participant.destroy!

    respond_to do |format|
      format.html { redirect_to walk_participants_path, status: :see_other, notice: "Walk participant was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_walk_participant
      @walk_participant = WalkParticipant.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def walk_participant_params
      params.expect(walk_participant: [ :walk_event_id, :user_id, :pet_id, :status, :joined_at ])
    end
end
