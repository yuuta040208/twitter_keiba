class AddColumnToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :tanshou, :integer
    add_column :users, :fukushou, :integer
  end
end
