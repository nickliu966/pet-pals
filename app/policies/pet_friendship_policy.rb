class PetFriendshipPolicy < ApplicationPolicy
  def update?
    receiver_owner?
  end

  def destroy?
    requester_owner? || receiver_owner?
  end

  private

  def requester_owner?
    record.requester_pet.user == user
  end

  def receiver_owner?
    record.receiver_pet.user == user
  end
end
