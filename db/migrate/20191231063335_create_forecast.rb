class CreateForecast < ActiveRecord::Migration[6.0]
  def change
    create_table :forecasts do |t|
      t.references :race
      t.references :user, type: :string, null: false
      t.references :tweet, type: :string, null: false
      t.string :honmei
      t.string :taikou
      t.string :tanana
      t.string :renka

      t.timestamps
    end
  end
end
