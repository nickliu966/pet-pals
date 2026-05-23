class ApplicationController < ActionController::Base
  before_action :authenticate_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_user_search, if: -> { current_user.present? }

  def set_user_search
    @q = User.all.ransack(params[:q])
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
        :website,
        :private,
        :avatar_image,
        :profile_banner,
      ],
    )
  end
end
