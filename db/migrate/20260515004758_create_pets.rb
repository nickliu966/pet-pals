class CreatePets < ActiveRecord::Migration[8.0]
  def change
    create_table :pets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :species
      t.string :breed
      t.string :gender
      t.date :birthday
      t.string :size
      t.string :energy_level
      t.string :temperament
      t.boolean :vaccinated
      t.boolean :neutered
      t.text :bio

      t.timestamps
    end
  end
end
