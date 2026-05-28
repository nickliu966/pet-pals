# == Schema Information
#
# Table name: mentions
#
#  id               :bigint           not null, primary key
#  mention_text     :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  mentioned_pet_id :bigint
#  mentioner_id     :bigint           not null
#  post_id          :bigint           not null
#  recipient_id     :bigint           not null
#
class Mention < ApplicationRecord
  belongs_to :post
  belongs_to :mentioner, class_name: "User"
  belongs_to :recipient, class_name: "User"
  belongs_to :mentioned_pet, class_name: "Pet", optional: true

  validates :mention_text, presence: true

  def self.sync_for_post(post)
    desired_attrs = desired_mentions_for(post)
    desired_keys = desired_attrs.map { |attrs| key_for_attrs(attrs) }

    post.mentions.each do |mention|
      mention.destroy unless desired_keys.include?(key_for_mention(mention))
    end

    existing_keys = post.mentions.reload.map { |mention| key_for_mention(mention) }

    desired_attrs.each do |attrs|
      next if existing_keys.include?(key_for_attrs(attrs))

      create!(attrs)
    end
  end

  def self.desired_mentions_for(post)
    tokens = extract_tokens(post.body)
    return [] if tokens.empty?

    mentioned_users =
      User
        .where(username: tokens)
        .where.not(id: post.user_id)
        .index_by { |user| user.username.downcase }

    user_mention_tokens = mentioned_users.keys
    pet_tokens = tokens - user_mention_tokens

    attrs = user_mentions_for(post, mentioned_users)

    attrs.concat(pet_mentions_for(post, pet_tokens)) if pet_tokens.any?

    attrs.uniq { |attrs_for_mention| key_for_attrs(attrs_for_mention) }
  end

  def self.user_mentions_for(post, mentioned_users)
    mentioned_users.map do |token, user|
      {
        post: post,
        mentioner: post.user,
        recipient: user,
        mention_text: token
      }
    end
  end

  def self.pet_mentions_for(post, pet_tokens)
    pets_by_name =
      Pet
        .includes(:user)
        .where("LOWER(pets.name) IN (?)", pet_tokens)
        .where.not(user_id: post.user_id)
        .group_by { |pet| pet.name.downcase }

    pets_by_name.each_with_object([]) do |(token, pets), attrs|
      next unless pets.one?

      pet = pets.first

      attrs << {
        post: post,
        mentioner: post.user,
        recipient: pet.user,
        mentioned_pet: pet,
        mention_text: token
      }
    end
  end

  def self.extract_tokens(text)
    text.to_s
        .scan(/@([A-Za-z0-9_.]+)/)
        .flatten
        .map(&:downcase)
        .uniq
  end

  def self.key_for_attrs(attrs)
    [
      attrs.fetch(:recipient).id,
      attrs[:mentioned_pet]&.id,
      attrs.fetch(:mention_text).to_s.downcase
    ]
  end

  def self.key_for_mention(mention)
    [
      mention.recipient_id,
      mention.mentioned_pet_id,
      mention.mention_text.to_s.downcase
    ]
  end
end
