class AddSomeColumnsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :total_win_taikou, :integer
    add_column :users, :total_place_taikou, :integer
    add_column :users, :total_win_tanana, :integer
    add_column :users, :total_place_tanana, :integer
    add_column :users, :total_win_renka, :integer
    add_column :users, :total_place_renka, :integer
  end
end
