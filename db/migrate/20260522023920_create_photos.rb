class CreatePhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :photos do |t|
      t.string :image
      t.text :caption
      t.references :owner, null: false, foreign_key: true
      t.boolean :pinned
      t.integer :comments_count
      t.integer :likes_count

      t.timestamps
    end
  end
end
