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

  def invite_participant?
    host?
  end

  def mark_attended?
    record.attendance_claimable_by?(user)
  end

  private

  def host?
    record.host_user == user
  end
end
