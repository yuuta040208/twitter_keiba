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

  desc 'ユーザの統計情報を計算'
  task :user_stats => :environment do
    User.all.includes(forecasts: :hit).each do |user|
      if user.forecasts.present?

        stat = Stat.find_or_initialize_by(user_id: user.id)
        honmei_stat = HonmeiStat.find_or_initialize_by(stat_id: stat.id)

        user_forecasts = user.forecasts.includes(:hit)
        wins = user_forecasts.select {|forecast| forecast.hit&.honmei_tanshou.present?}
        places = user_forecasts.select {|forecast| forecast.hit&.honmei_fukushou.present?}

        ActiveRecord::Base.transaction do
          stat.user_id = user.id
          stat.forecast_count = user.forecasts.count
          stat.save!

          honmei_stat.stat_id = stat.id
          honmei_stat.win_return_rate = ((wins.sum {|forecast| forecast.hit.honmei_tanshou}.to_f / (stat.forecast_count * 100)) * 100).round(2)
          honmei_stat.place_return_rate = ((places.sum {|forecast| forecast.hit.honmei_fukushou}.to_f / (stat.forecast_count * 100)) * 100).round(2)
          honmei_stat.win_hit_rate = ((wins.count.to_f / stat.forecast_count) * 100).round(2)
          honmei_stat.place_hit_rate = ((places.count.to_f / stat.forecast_count) * 100).round(2)
          honmei_stat.save!
        end

        puts "#{user.name}: #{honmei_stat.attributes}"
      end
    end
  end
end
