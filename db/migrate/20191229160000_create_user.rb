class CreateUser < ActiveRecord::Migration[6.0]
  def change
    create_table :users, {id: :string} do |t|
      t.string :name
      t.text :url
      t.text :image_url
      t.integer :point, default: 0

      t.timestamps
    end
  end
end
