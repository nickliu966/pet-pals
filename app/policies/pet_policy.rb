class PetPolicy < ApplicationPolicy
  def show?
    true
  end

  def edit?
    owner?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  private

  def owner?
    record.user == user
  end
end
