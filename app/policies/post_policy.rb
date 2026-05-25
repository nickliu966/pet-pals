class PostPolicy < ApplicationPolicy
  def show?
    owner? || public_post? || visible_through_owner_friendship? || visible_through_pet_friendship?
  end

  def edit?
    owner?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  private

  def owner?
    record.user == user
  end

  def public_post?
    record.everyone?
  end

  def visible_through_owner_friendship?
    return false unless record.user.present?

    owner_friend? &&
      (record.user_friends_only? || record.friends_of_either?)
  end

  def visible_through_pet_friendship?
    return false unless record.pet.present?

    pet_friend? &&
      (record.pet_friends_only? || record.friends_of_either?)
  end

  def owner_friend?
    user.owner_friends.include?(record.user) ||
      user.friended_by_users.include?(record.user)
  end

  def pet_friend?
    user.pets.any? do |pet|
      pet.pet_friends.include?(record.pet) ||
        pet.friended_by_pets.include?(record.pet)
    end
  end
end
