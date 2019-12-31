class CreateTweet < ActiveRecord::Migration[6.0]
  def change
    create_table :tweets do |t|
      t.references :race, index: true
      t.string :unique_id
      t.string :user_id
      t.string :user_name
      t.text :user_uri
      t.text :content
      t.datetime :tweeted_at

      t.timestamps
    end
  end
end
