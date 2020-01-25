class AddColumnToResult < ActiveRecord::Migration[6.0]
  def change
    add_column :results, :tanshou, :integer
    add_column :results, :fukushou_first, :integer
    add_column :results, :fukushou_second, :integer
    add_column :results, :fukushou_third, :integer
  end
end
