class NotificationsController < ApplicationController
  def index
    @owner_requests = current_user.pending_received_user_friendships
    @pet_requests = PetFriendship.pending.where(receiver_pet: current_user.pets)

    @walk_invitations =
      WalkParticipant
        .invited
        .where(user: current_user)
        .includes(:pet, walk_event: [ :host_user, :host_pet ])
        .order(created_at: :desc)

    @post_likes = Like.where(post: current_user.posts)
                      .where.not(fan: current_user)
                      .order(created_at: :desc)

    @post_comments = Comment.where(post: current_user.posts)
                            .where.not(author: current_user.id)
                            .order(created_at: :desc)

    current_user.update(notifications_read_at: Time.current)
  end
end
