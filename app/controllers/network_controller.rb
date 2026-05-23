class NetworkController < ApplicationController
  def index
    @received_owner_requests = current_user.received_user_friendships.pending
    @sent_owner_requests = current_user.sent_user_friendships.pending
    @owner_friends = (current_user.owner_friends + current_user.friended_by_users).uniq

    @received_pet_requests = PetFriendship.pending.where(receiver_pet: current_user.pets)
    @sent_pet_requests = PetFriendship.pending.where(requester_pet: current_user.pets)

    @pet_friendships =
      PetFriendship.accepted
                   .where(requester_pet: current_user.pets)
                   .or(PetFriendship.accepted.where(receiver_pet: current_user.pets))
  end
end
