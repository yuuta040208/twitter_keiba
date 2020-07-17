class AddPlaceEtcToRaces < ActiveRecord::Migration[6.0]
  def change
    add_column :races, :times, :integer
    add_column :races, :day, :integer
    add_column :races, :place, :string
    add_column :races, :course, :string
    add_column :races, :distance, :integer
  end
end
