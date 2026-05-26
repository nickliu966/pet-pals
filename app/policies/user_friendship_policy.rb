class UserFriendshipPolicy < ApplicationPolicy
  def update?
    receiver?
  end

  def destroy?
    requester? || receiver?
  end

  private

  def requester?
    record.requester == user
  end

  def receiver?
    record.receiver == user
  end
end
