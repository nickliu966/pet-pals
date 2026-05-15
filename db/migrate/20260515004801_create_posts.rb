class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pet, null: false, foreign_key: true
      t.text :body
      t.integer :visibility

      t.timestamps
    end
  end
end
