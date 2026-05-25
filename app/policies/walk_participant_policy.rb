class WalkParticipantPolicy < ApplicationPolicy
  def destroy?
    participant? || walk_host?
  end

  private

  def participant?
    record.user == user
  end

  def walk_host?
    record.walk_event.host_user == user
  end
end
