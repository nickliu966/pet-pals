class WalkParticipantPolicy < ApplicationPolicy
  def destroy?
    participant? || walk_host?
  end

  def accept?
    invited_participant?
  end

  def decline?
    invited_participant?
  end

  private

  def participant?
    record.user == user
  end

  def walk_host?
    record.walk_event.host_user == user
  end

  def invited_participant?
    record.user == user && record.invited?
  end
end
