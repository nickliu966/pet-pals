class PetsController < ApplicationController
  before_action :set_pet, only: [ :show, :edit, :update, :destroy ]

  def show
  end

  def new
    @pet = current_user.pets.build
  end

  def edit
    authorize! @pet
  end

  def create
    @pet = current_user.pets.build(pet_params)

    respond_to do |format|
      if @pet.save
        format.html { redirect_to @pet, notice: "Pet was successfully created." }
        format.json { render :show, status: :created, location: @pet }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pet.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize! @pet

    respond_to do |format|
      if @pet.update(pet_params)
        format.html { redirect_to @pet, notice: "Pet was successfully updated." }
        format.json { render :show, status: :ok, location: @pet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pet.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize! @pet

    @pet.destroy!

    respond_to do |format|
      format.html { redirect_back fallback_location: root_url, notice: "Pet was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_pet
    @pet = Pet.find(params.expect(:id))
  end

  def pet_params
    params.expect(
      pet: [
        :name,
        :species,
        :breed,
        :gender,
        :birthday,
        :size,
        :energy_level,
        :temperament,
        :vaccinated,
        :bio,
        :image_url,
        :image
      ]
    )
  end
end
