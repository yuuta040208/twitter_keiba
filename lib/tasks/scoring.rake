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

      count = 0
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

        if forecast.present? && Forecast.where(race_id: race.id, user_id: tweet.user.id).empty?
          Forecast.create!(
              race_id: race.id,
              user_id: tweet.user.id,
              tweet_id: tweet.id,
              honmei: forecast[:honmei],
              taikou: forecast[:taikou],
              tanana: forecast[:tanana],
              renka: forecast[:renka],
          )
          count += 1
        end
      end

      puts "#{count}件のスコアリングを完了しました。"
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
        end
      end

      puts "#{count}件のスコアリングを完了しました。"
    end
  end
end
