class CreateMentions < ActiveRecord::Migration[8.0]
  def change
    create_table :mentions do |t|
      t.references :post, null: false, foreign_key: true

      t.references :mentioner,
                   null: false,
                   foreign_key: { to_table: :users }

      t.references :recipient,
                   null: false,
                   foreign_key: { to_table: :users }

      t.references :mentioned_pet,
                   foreign_key: { to_table: :pets }

      t.string :mention_text, null: false

      t.timestamps
    end

    add_index :mentions,
              [ :post_id, :recipient_id, :mentioned_pet_id, :mention_text ],
              unique: true,
              name: "index_mentions_on_post_recipient_pet_and_text"
  end
end
