class CreateOdds < ActiveRecord::Migration[6.0]
  def change
    create_table :odds do |t|
      t.references :race, foreign_key: true
      t.references :horse, foreign_key: true
      t.integer :time
      t.float :win
      t.float :place

      t.timestamps
    end
  end
end
