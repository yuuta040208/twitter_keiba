class ChangeColumnNameToHorse < ActiveRecord::Migration[6.0]
  def change
    rename_column :horses, :odds, :win
  end
end
