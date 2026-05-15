class ApplicationController < ActionController::Base
   helper_method :current_user

  private

  def current_user
    @current_user ||= User.first || User.create!(
      name: "Demo User",
      email: "demo@example.com",
      city: "Chicago"
    )
  end
end
