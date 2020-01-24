class ChangeColumnToRace < ActiveRecord::Migration[6.0]
  def change
    add_column :races, :time, :string
  end
end
