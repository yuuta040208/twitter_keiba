class CreateUser < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.references :tweet, index: true
      t.references :forecast, index: true
      t.string :twitter_user_id
      t.string :twitter_user_name
      t.integer :point
    end
  end
end
