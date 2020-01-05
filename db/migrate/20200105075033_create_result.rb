class CreateResult < ActiveRecord::Migration[6.0]
  def change
    create_table :results do |t|
      t.references :race, index: true
      t.string :first
      t.string :second
      t.string :third
    end
  end
end
