# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_02_063112) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "forecasts", force: :cascade do |t|
    t.bigint "race_id"
    t.string "user_id", null: false
    t.string "tweet_id", null: false
    t.string "honmei"
    t.string "taikou"
    t.string "tanana"
    t.string "renka"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["race_id"], name: "index_forecasts_on_race_id"
    t.index ["tweet_id"], name: "index_forecasts_on_tweet_id"
    t.index ["user_id"], name: "index_forecasts_on_user_id"
  end

  create_table "hits", force: :cascade do |t|
    t.bigint "race_id"
    t.bigint "forecast_id"
    t.integer "honmei_tanshou"
    t.integer "honmei_fukushou"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["forecast_id"], name: "index_hits_on_forecast_id"
    t.index ["race_id"], name: "index_hits_on_race_id"
  end

  create_table "horses", force: :cascade do |t|
    t.bigint "race_id"
    t.string "name"
    t.integer "wakuban"
    t.integer "umaban"
    t.string "jockey_name"
    t.float "win"
    t.integer "popularity"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["race_id"], name: "index_horses_on_race_id"
  end

  create_table "odds", force: :cascade do |t|
    t.bigint "race_id"
    t.bigint "horse_id"
    t.integer "time"
    t.float "win"
    t.float "place"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["horse_id"], name: "index_odds_on_horse_id"
    t.index ["race_id"], name: "index_odds_on_race_id"
  end

  create_table "races", force: :cascade do |t|
    t.string "date"
    t.string "number"
    t.string "hold"
    t.string "name"
    t.text "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "time"
    t.string "alt_name"
  end

  create_table "results", force: :cascade do |t|
    t.bigint "race_id"
    t.string "first_horse"
    t.string "second_horse"
    t.string "third_horse"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "tanshou"
    t.integer "fukushou_first"
    t.integer "fukushou_second"
    t.integer "fukushou_third"
    t.index ["race_id"], name: "index_results_on_race_id"
  end

  create_table "tweets", id: :string, force: :cascade do |t|
    t.bigint "race_id"
    t.string "user_id", null: false
    t.text "content"
    t.text "url"
    t.datetime "tweeted_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["race_id"], name: "index_tweets_on_race_id"
    t.index ["user_id"], name: "index_tweets_on_user_id"
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.string "name"
    t.text "url"
    t.text "image_url"
    t.integer "point", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "tanshou"
    t.integer "fukushou"
  end

  add_foreign_key "odds", "horses"
  add_foreign_key "odds", "races"
end
