class CreateStats < ActiveRecord::Migration[6.0]
  def change
    create_table :stats do |t|
      t.references :user, type: :string, null: false
      t.integer :forecast_count
      t.float :average_odds

      t.timestamps
    end
  end
end
