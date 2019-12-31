class CreateForecast < ActiveRecord::Migration[6.0]
  def change
    create_table :forecasts do |t|
      t.references :tweet, index: true
      t.references :race, index: true
      t.string :honmei
      t.string :taikou
      t.string :tanana
      t.string :renka

      t.timestamps
    end
  end
end
