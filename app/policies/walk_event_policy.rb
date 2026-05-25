class WalkEventPolicy < ApplicationPolicy
  def show?
    true
  end

  def edit?
    host?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  private

  def host?
    record.host_user == user
  end
end
