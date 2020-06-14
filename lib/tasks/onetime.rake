namespace :onetime do
  desc "平均購入オッズを計算"
  task :user_odds => :environment do
    User.transaction do
      User.all.each do |user|
        wins = user.forecasts.map {|forecast| forecast.race.horses.find_by(name: forecast.honmei)&.win}.compact
        next if wins.size.zero?

        average_win = (wins.sum / wins.size).round(2)

        user.update!(average_win: average_win)
        puts "#{user.name}: #{average_win}"
      end
    end
  end
end
