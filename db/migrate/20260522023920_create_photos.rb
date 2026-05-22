class CreatePhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :photos do |t|
      t.string :image
      t.text :caption
      t.belongs_to :owner, null: false, foreign_key: { to_table: :users }
      t.boolean :pinned, default: false, null: false
      t.integer :comments_count, default: 0
      t.integer :likes_count, default: 0

      t.timestamps
    end
  end
end
