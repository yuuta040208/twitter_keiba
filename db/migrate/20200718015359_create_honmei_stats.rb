class CreateHonmeiStats < ActiveRecord::Migration[6.0]
  def change
    create_table :honmei_stats do |t|
      t.references :stat
      t.float :win_return_rate
      t.float :place_return_rate
      t.float :win_hit_rate
      t.float :place_hit_rate

      t.timestamps
    end
  end
end
