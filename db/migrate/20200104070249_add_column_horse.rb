class AddColumnHorse < ActiveRecord::Migration[6.0]
  def up
    add_column :horses, :wakuban, :integer
    add_column :horses, :umaban, :integer
    add_column :horses, :jockey_name, :string
    add_column :horses, :odds, :float
    add_column :horses, :popularity, :integer

  end

  def down
    remove_column :horses, :wakuban, :integer
    remove_column :horses, :umaban, :integer
    remove_column :horses, :jockey_name, :string
    remove_column :horses, :odds, :float
    remove_column :horses, :popularity, :integer
  end
end
