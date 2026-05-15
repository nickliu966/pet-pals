class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.references :post, null: false, foreign_key: true
      t.text :body, null: false
      t.integer :parent_comment_id

      t.timestamps
    end
  end
end
