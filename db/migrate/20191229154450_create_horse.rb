class CreateHorse < ActiveRecord::Migration[6.0]
  def change
    create_table :horses do |t|
      t.references :race, index: true
      t.string :name

      t.timestamps
    end
  end
end
