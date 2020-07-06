namespace :line do
  desc 'メッセージを配信'
  task :broadcast, ['id'] => :environment do |_, args|
    race = Race.find(args['id'].to_i)
    carousels = race.line_tweets(limit: 10).map do |tweet|
      user_stat = tweet.user.user_stat
      texts = ["単勝回収率: #{user_stat.return_rate_win}%, 複勝回収率: #{user_stat.return_rate_place}%"]
      texts << "◎　#{tweet.forecast.honmei}" if tweet.forecast.honmei
      texts << "○　#{tweet.forecast.taikou}" if tweet.forecast.taikou
      texts << "▲　#{tweet.forecast.tanana}" if tweet.forecast.tanana && texts.size < 2
      texts << "△　#{tweet.forecast.renka}" if tweet.forecast.renka && texts.size < 2

      Line::Carousel.new(title: "#{tweet.user_name} (予想数: #{user_stat.forecasts_count})", text: texts.join("\n"), url: "https://twitter-keiba.herokuapp.com/forecasts/#{tweet.forecast.id}")
    end

    LineApi::Client.broadcast_messages(Line::Template.new(carousels: carousels, alt: race.name))
  end
end
