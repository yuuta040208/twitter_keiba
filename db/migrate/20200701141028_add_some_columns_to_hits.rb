class AddSomeColumnsToHits < ActiveRecord::Migration[6.0]
  def change
    add_column :hits, :taikou_tanshou, :integer
    add_column :hits, :taikou_fukushou, :integer
    add_column :hits, :tanana_tanshou, :integer
    add_column :hits, :tanana_fukushou, :integer
    add_column :hits, :renka_tanshou, :integer
    add_column :hits, :renka_fukushou, :integer
  end
end
