class CommentPolicy < ApplicationPolicy
  def edit?
    author?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end

  private

  def author?
    record.author == user
  end
end
