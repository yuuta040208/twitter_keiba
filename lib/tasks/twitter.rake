require 'twitter'

namespace :twitter do
  desc "ツイートを馬名で検索"
  task :search, ['date'] => :environment do |task, args|

    client = api_client

    Race.where(date: "#{Date.today.year}#{args['date']}").each do |race|
      queries = [race.name]

      if race.hold.include?('回') && race.hold.to_i != 0
        place = Race.last.hold.split('回').last.split(/\d/).first
        queries.push("#{place}#{race.number}")
      end

      if race.name.end_with?('ステークス')
        queries.push(race.name.gsub('ステークス', '') + 'S')
        queries.push(race.name.gsub('ステークス', '') + 'Ｓ')
      end

      if race.name.end_with?('S') || race.name.end_with?('Ｓ')
        queries.push(race.name.chop + 'S') if race.name.end_with?('Ｓ')
        queries.push(race.name.chop + 'Ｓ') if race.name.end_with?('S')
        queries.push(race.name.chop + 'ステークス')
      end

      if race.alt_name.present?
        queries.push(race.alt_name)
      end

      query = "(#{queries.join(' OR ')}) ◎"
      last_tweet_id = race.tweets.order(tweeted_at: 'desc').first&.id

      puts "#{query} をTwitterで検索します..."

      count = 0
      begin
        client.search(query, count: 50, result_type: 'recent', exclude: 'retweets', since_id: last_tweet_id).each do |tweet|
          race_time = race.time.gsub(':', '').to_i
          tweet_time = tweet.created_at.in_time_zone('Tokyo').strftime('%H%M').to_i

          if race_time > tweet_time
            if User.where(id: tweet.user.id).empty?
              User.create!(
                  id: tweet.user.id,
                  name: tweet.user.name,
                  url: tweet.user.url,
                  image_url: tweet.user.profile_image_url,
              )
            else
              user = User.find_by(id: tweet.user.id)
              if user.present? && user.name != tweet.user.name
                user.update!(
                    name: tweet.user.name,
                    url: tweet.user.url,
                    image_url: tweet.user.profile_image_url,
                )
              end
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

            count += 1
          end
        end
      rescue => e
        puts e
      end

      puts "#{count}件をデータベースに追加しました。"

      # APIリミットに到達しないように30秒スリープさせる
      sleep 30
    end
  end

  desc 'ツイートする'
  task :tweet, ['id'] => :environment do |_, args|
    race = Race.find(args['id'].to_i)
    tweet = race.line_tweets(limit: 1).first
    text = "#{race.name}の予想が配信されたよ！イチオシの予想家はこちら！\n#{tweet.url}\n\n予想をもっと見たい人は、Webサイトをチェック！\nhttps://twitter-keiba.herokuapp.com/"

    api_client_evikeiba.update(text)
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

  def api_client_evikeiba
    Twitter::REST::Client.new(
        consumer_key: Rails.application.credentials.twitter2[:consumer_key],
        consumer_secret: Rails.application.credentials.twitter2[:consumer_secret],
        access_token: Rails.application.credentials.twitter2[:access_token],
        access_token_secret: Rails.application.credentials.twitter2[:access_token_secret],
    )
  end
end
