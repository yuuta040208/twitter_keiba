desc "This task is called by the Heroku scheduler add-on"
task :scheduler => :environment do
  races = Race.where(date: Date.today.strftime("%Y%m%d"))
  last_race = races.max{|a, b| a.time.gsub(':', '').to_i <=> b.time.gsub(':', '').to_i}

  if races.blank?
    puts 'レース情報を取得'
    Rake::Task['weekly:scrape'].invoke(Date.today.strftime("%m%d"))

  else
    now = (Time.now + 9 * 60 * 60).strftime("%H%M")
    now = now.end_with?('0') ? now.slice(1..-1) : now
    last_race_time = last_race.time.gsub(':', '')

    if  now.to_i < last_race_time.to_i && 1200 < now.to_i
      puts 'ツイートを検索'
      Rake::Task['weekly:tweet'].invoke(Date.today.strftime("%m%d"))

      puts 'オッズを更新'
      Rake::Task['weekly:odds'].invoke(Date.today.strftime("%m%d"))

      puts 'キャッシュをクリア'
      races.each do |race|
        Rails.cache.delete_matched("cache_forecasts_#{race.id}_*")
        Rails.cache.delete("cache_twitter_rates_#{race.id}")
      end

    elsif last_race_time.to_i <= now.to_i

      results = Result.where(race_id: last_race.id)
      if results.empty?
        puts '結果情報を取得'
        Rake::Task['weekly:result'].invoke(Date.today.strftime("%m%d"))
      else
        puts '実行するスクリプトはありません'
      end

    else
      puts '実行するスクリプトはありません'
    end
  end
end
