class CreateHit < ActiveRecord::Migration[6.0]
  def change
    create_table :hits do |t|
      t.references :race
      t.references :forecast
      t.integer :honmei_tanshou
      t.integer :honmei_fukushou

      t.timestamps
    end
  end
end
