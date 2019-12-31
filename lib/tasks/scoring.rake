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
end
