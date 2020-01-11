require 'twitter'

namespace :twitter do
  desc "ツイートを馬名で検索"
  task :search, ['date'] => :environment do |task, args|

    client = api_client

    Race.where(date: "#{Date.today.year}#{args['date']}").each do |race|
      queries = [race.name]
      queries.push(race.name.chop + 'ステークス') if race.name.end_with?('S') || race.name.end_with?('Ｓ')
      query = queries.join(' OR ')

      puts "#{query} をTwitterで検索します..."

      begin
        client.search(query, count: 1000, result_type: 'recent', exclude: 'retweets').each do |tweet|
          if tweet.text.include?('◎')
            if User.where(id: tweet.user.id).empty?
              User.create!(
                  id: tweet.user.id,
                  name: tweet.user.name,
                  url: tweet.user.url,
                  image_url: tweet.user.profile_image_url,
              )
            end

            if Tweet.where(id: tweet.id).empty?
              Tweet.create!(
                  id: tweet.id,
                  race_id: race.id,
                  user_id: tweet.user.id,
                  content: tweet.text,
                  url: tweet.uri,
                  tweeted_at: tweet.created_at,
              )
            end
          end
        end
      rescue => e
        puts e
      end

      puts "#{Tweet.where(race_id: race.id).count}件をデータベースに追加しました。"

      # APIリミットに到達しないように30秒スリープさせる
      sleep 30
    end
  end


  desc "APIのリミットを取得"
  task :limit do
    client = api_client
    puts client.__send__(:perform_get, '/1.1/application/rate_limit_status.json')[:resources][:search][:"/search/tweets"]
  end


  private

  def api_client
    Twitter::REST::Client.new(
        consumer_key: Rails.application.credentials.twitter[:consumer_key],
        consumer_secret: Rails.application.credentials.twitter[:consumer_secret],
        access_token: Rails.application.credentials.twitter[:access_token],
        access_token_secret: Rails.application.credentials.twitter[:access_token_secret],
    )
  end
end
