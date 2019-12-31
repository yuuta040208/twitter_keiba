class CreateRace < ActiveRecord::Migration[6.0]
  def change
    create_table :races do |t|
      t.string :date
      t.string :name
      t.text :url

      t.timestamps
    end
  end
end
