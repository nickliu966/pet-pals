class UserPolicy < ApplicationPolicy
  def show?
    record == user ||
      !record.private? ||
      user.friends_with?(record)
  end

  def view_private_content?
    show?
  end
end
