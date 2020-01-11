class CreateTweet < ActiveRecord::Migration[6.0]
  def change
    create_table :tweets, {id: :string}  do |t|
      t.references :race
      t.references :user, type: :string, null: false
      t.text :content
      t.text :url
      t.datetime :tweeted_at

      t.timestamps
    end
  end
end
