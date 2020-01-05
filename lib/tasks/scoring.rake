namespace :scoring do
  desc "ツイートを馬名で検索"
  task :create, ['date'] => :environment do |task, args|
    regex = /(\s|　|[ァ-ヴ])*/
    marks = [
        {mark: '◎', type: :honmei},
        {mark: /[○◯]/, type: :taikou},
        {mark: '▲', type: :tanana},
        {mark: '△', type: :renka},
    ]

    Race.where(date: "#{Date.today.year}#{args['date']}").each do |race|
      puts "#{race.name} のスコアリング中..."

      race.tweets.each do |tweet|
        forecast = {}
        marks.each do |mark|
          race.horses.each do |horse|
            if tweet.content.match("#{mark[:mark]}#{regex}#{horse.name}").present?
              forecast[mark[:type]] = horse.name
              break
            end
          end
        end

        if forecast.present?
          Forecast.create!(
              race_id: race.id,
              tweet_id: tweet.id,
              honmei: forecast[:honmei],
              taikou: forecast[:taikou],
              tanana: forecast[:tanana],
              renka: forecast[:renka],
          )
        end
      end

      puts "#{Forecast.where(race_id: race.id).count}件のスコアリングを完了しました。"
    end
  end

  desc "的中した予想を取得"
  task :result, ['date'] => :environment do |task, args|
    Race.where(date: "#{Date.today.year}#{args['date']}").each do |race|
      puts "#{race.name} の的中ツイートを取得中..."

      users = []
      result = Result.find_by(race_id: race.id)
      return if result.nil?

      Forecast.where(race_id: race.id).each do |forecast|
        point = 0

        if forecast.honmei == result.first
          point += 10
        elsif forecast.taikou == result.first
          point += 5
        elsif forecast.tanana == result.first
          point += 2
        elsif forecast.renka == result.first
          point += 1
        end

        if forecast.honmei == result.second
          point += 3
        elsif forecast.taikou == result.second
          point += 5
        elsif forecast.tanana == result.second
          point += 1
        end

        if point > 0 && users.exclude?(forecast.tweet.user_id)
          user = User.find_by(twitter_user_id: forecast.tweet.user_id)
          if user.present?
            user.point = user.point + point
            user.save!
          else
            User.create(
                tweet_id: forecast.tweet.id,
                forecast_id: forecast.id,
                twitter_user_id: forecast.tweet.user_id,
                twitter_user_name: forecast.tweet.user_name,
                point: point,
            )
          end

          users.push(forecast.tweet.user_id)
        end
      end
    end
  end
end
