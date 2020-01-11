class CreateHorse < ActiveRecord::Migration[6.0]
  def change
    create_table :horses do |t|
      t.references :race
      t.string :name
      t.integer :wakuban
      t.integer :umaban
      t.string :jockey_name
      t.float :odds
      t.integer :popularity

      t.timestamps
    end
  end
end
