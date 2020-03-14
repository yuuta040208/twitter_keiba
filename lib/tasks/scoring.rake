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

      create_count = 0
      update_count = 0
      race.tweets.where(tweets: {id: Tweet.group(:user_id).select('max(id)')}).each do |tweet|
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
          exist_forecast = Forecast.where(race_id: race.id, user_id: tweet.user.id).first
          if exist_forecast.nil?
            Forecast.create!(
                race_id: race.id,
                user_id: tweet.user.id,
                tweet_id: tweet.id,
                honmei: forecast[:honmei],
                taikou: forecast[:taikou],
                tanana: forecast[:tanana],
                renka: forecast[:renka],
            )

            create_count += 1
          else
            if tweet.id != exist_forecast.tweet.id
              exist_forecast.tweet_id = tweet.id
              exist_forecast.honmei = forecast[:honmei]
              exist_forecast.taikou = forecast[:taikou]
              exist_forecast.tanana = forecast[:tanana]
              exist_forecast.renka = forecast[:renka]
              exist_forecast.save!

              update_count += 1
            end
          end
        end
      end

      puts "#{create_count + update_count}(新規: #{create_count}、更新: #{update_count})件のスコアリングを完了しました。"
    end
  end

  desc "的中した予想を取得"
  task :result, ['date'] => :environment do |task, args|
    Race.where(date: "#{Date.today.year}#{args['date']}").each do |race|
      puts "#{race.name} の的中ツイートを取得中..."

      result = Result.find_by(race_id: race.id)
      return if result.nil?

      count = 0
      Forecast.where(race_id: race.id).each do |forecast|
        point = 0

        if forecast.honmei == result.first_horse
          point += 10
        elsif forecast.taikou == result.first_horse
          point += 5
        elsif forecast.tanana == result.first_horse
          point += 2
        elsif forecast.renka == result.first_horse
          point += 1
        end

        if forecast.honmei == result.second_horse
          point += 3
        elsif forecast.taikou == result.second_horse
          point += 5
        elsif forecast.tanana == result.second_horse
          point += 1
        end

        if point > 0
          user = forecast.user
          user.point = user.point + point
          user.save!
          count += 1
        end
      end

      puts "#{count}件のスコアリングを完了しました。"
    end
  end

  desc "ユーザごとの回収金額を計算"
  task :sum, ['date'] => :environment do |task, args|
    races = if args['date'].present?
              Race.joins(forecasts: :user).joins(:result).distinct.where(date: "#{Date.today.year}#{args['date']}")
            else
              Race.joins(forecasts: :user).joins(:result).distinct.all
            end
    races.each do |race|
      race.forecasts.each do |forecast|
        case forecast.honmei
        when race.result.first_horse then
          forecast.user.tanshou = race.result.tanshou + (forecast.user.tanshou || 0)
          forecast.user.fukushou = race.result.fukushou_first + (forecast.user.fukushou || 0)
          race.hit.tanshou = race.result.tanshou
          race.hit.fukushou = race.result.fukushou
        when race.result.second_horse then
          forecast.user.fukushou = race.result.fukushou_second + (forecast.user.fukushou || 0)
          race.hit.fukushou = race.result.fukushou
        when race.result.third_horse then
          forecast.user.fukushou = race.result.fukushou_third + (forecast.user.fukushou || 0)
          race.hit.fukushou = race.result.fukushou
        else
          next
        end

        forecast.user.save!
        race.hit.save!
        puts "#{forecast.user.name}: #{forecast.user.tanshou}円, #{forecast.user.fukushou}円"
      end
    end
  end

  desc "的中計算"
  task :hit, ['date'] => :environment do |task, args|
    races = if args['date'].present?
              Race.joins(forecasts: :user).joins(:result).distinct.where(date: "#{Date.today.year}#{args['date']}")
            else
              Race.joins(forecasts: :user).joins(:result).distinct.all
            end
    races.each do |race|
      race.forecasts.each do |forecast|
        hit = Hit.new(race_id: race.id, forecast_id: forecast.id)

        case forecast.honmei
        when race.result.first_horse then
          hit.honmei_tanshou = race.result.tanshou
          hit.honmei_fukushou = race.result.fukushou_first

        when race.result.second_horse then
          hit.honmei_fukushou = race.result.fukushou_second

        when race.result.third_horse then
          hit.honmei_fukushou = race.result.fukushou_third

        else
          next
        end

        hit.save!
        puts "#{forecast.user.name}: #{hit.honmei_tanshou}円, #{hit.honmei_fukushou}円"
      end
    end
  end
end
