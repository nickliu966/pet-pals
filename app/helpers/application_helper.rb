module ApplicationHelper
  def link_mentions(text)
    return "" if text.blank?

    tokens =
      text
        .scan(/@([A-Za-z0-9_.]+)/)
        .flatten
        .map(&:downcase)
        .uniq

    users_by_token =
      User
        .where(username: tokens)
        .index_by { |user| user.username.downcase }

    pets_by_token =
      Pet
        .where("LOWER(name) IN (?)", tokens)
        .order(:id)
        .index_by { |pet| pet.name.downcase }

    pieces = text.split(/(@[A-Za-z0-9_.]+)/)

    safe_join(
      pieces.map do |piece|
        if piece.start_with?("@")
          token = piece.delete_prefix("@").downcase

          if users_by_token[token].present?
            user = users_by_token[token]

            link_to piece,
                    user_path(user.username),
                    class: "mention-link"
          elsif pets_by_token[token].present?
            pet = pets_by_token[token]

            link_to piece,
                    pet_path(pet),
                    class: "mention-link mention-link-pet"
          else
            h(piece)
          end
        else
          h(piece)
        end
      end,
    )
  end
end
