class AddColumnToRaces < ActiveRecord::Migration[6.0]
  def change
    add_column :races, :alt_name, :string, after: :name
  end
end
