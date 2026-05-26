class UserPolicy < ApplicationPolicy
  def show?
    record == user ||
      !record.private? ||
      user.owner_friends.include?(record) ||
      user.friended_by_users.include?(record)
  end

  def view_private_content?
    show?
  end
end
