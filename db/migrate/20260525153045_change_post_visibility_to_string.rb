class ChangePostVisibilityToString < ActiveRecord::Migration[8.0]
  def up
    change_column_default :posts, :visibility, nil

    change_column :posts,
                  :visibility,
                  :string,
                  using: <<~SQL.squish
                    CASE visibility
                    WHEN 0 THEN 'everyone'
                    WHEN 1 THEN 'user_friends_only'
                    WHEN 2 THEN 'pet_friends_only'
                    WHEN 3 THEN 'friends_of_either'
                    ELSE 'everyone'
                    END
                  SQL

    change_column_default :posts, :visibility, "everyone"
    change_column_null :posts, :visibility, false
  end

  def down
    change_column_default :posts, :visibility, nil

    change_column :posts,
                  :visibility,
                  :integer,
                  using: <<~SQL.squish
                    CASE visibility
                    WHEN 'everyone' THEN 0
                    WHEN 'user_friends_only' THEN 1
                    WHEN 'pet_friends_only' THEN 2
                    WHEN 'friends_of_either' THEN 3
                    ELSE 0
                    END
                  SQL

    change_column_default :posts, :visibility, 0
    change_column_null :posts, :visibility, false
  end
end
