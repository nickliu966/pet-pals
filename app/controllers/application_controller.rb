class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_user_search, if: -> { current_user.present? }
  before_action :set_sidebar_suggestions, if: -> { current_user.present? }

  rescue_from ActionPolicy::Unauthorized, with: :user_not_authorized

  def set_user_search
    @q = User.all.ransack(params[:q])
  end

  def set_sidebar_suggestions
    excluded_user_ids =
      [current_user.id] +
      current_user.sent_user_friendships
                  .where(status: ["pending", "accepted"])
                  .pluck(:receiver_id)

    @suggested_users =
      User
        .left_joins(:posts)
        .where.not(id: excluded_user_ids.compact.uniq)
        .select("users.*, COUNT(posts.id) AS suggestion_posts_count")
        .group("users.id")
        .order(Arel.sql("COUNT(posts.id) DESC"), likes_count: :desc, created_at: :desc)
        .limit(3)

    user_pet_ids = current_user.pets.pluck(:id)

    connected_pet_ids =
      PetFriendship
        .where(requester_pet_id: user_pet_ids)
        .where(status: ["pending", "accepted"])
        .pluck(:receiver_pet_id) +
      PetFriendship
        .where(receiver_pet_id: user_pet_ids)
        .where(status: ["pending", "accepted"])
        .pluck(:requester_pet_id)

    excluded_pet_ids = (user_pet_ids + connected_pet_ids).compact.uniq

    @suggested_pets =
      Pet
        .includes(:user)
        .left_joins(:posts)
        .where.not(id: excluded_pet_ids)
        .select("pets.*, COUNT(posts.id) AS suggestion_posts_count")
        .group("pets.id")
        .order(Arel.sql("COUNT(posts.id) DESC"), created_at: :desc)
        .limit(3)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [:username],
    )

    devise_parameter_sanitizer.permit(
      :account_update,
      keys: [
        :username,
        :display_name,
        :bio,
        :city,
        :website,
        :private,
        :avatar_image,
        :profile_banner,
      ],
    )
  end

  private

  def user_not_authorized
    flash[:alert] = "You're not authorized for that."
    redirect_back fallback_location: root_url
  end
end
