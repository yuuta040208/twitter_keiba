class AddColumnAveragesToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :average_win, :float
    add_column :users, :average_place, :float
  end
end
