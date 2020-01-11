class CreateResult < ActiveRecord::Migration[6.0]
  def change
    create_table :results do |t|
      t.references :race
      t.string :first_horse
      t.string :second_horse
      t.string :third_horse

      t.timestamps
    end
  end
end
