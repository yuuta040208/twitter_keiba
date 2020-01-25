desc "This task is called by the Heroku scheduler add-on"
task :scheduler => :environment do
  races = Race.where(date: Date.today.strftime("%Y%m%d"))

  if races.blank?
    puts 'レース情報を取得'
    Rake::Task['weekly:scrape'].invoke(Date.today.strftime("%m%d"))

  else
    now = (Time.now + 9 * 60 * 60).strftime("%H%M")
    now = now.end_with?('0') ? now.slice(1..-1) : now
    last_race_time = races.last.time.gsub(':', '')

    if  now.to_i < last_race_time.to_i && 1400 < now.to_i
      puts 'ツイートを検索'
      Rake::Task['weekly:tweet'].invoke(Date.today.strftime("%m%d"))

    elsif last_race_time.to_i <= now.to_i

      results = Result.where(race_id: races.first.id)
      if results.empty?
        puts '結果情報を取得'
        puts now
        puts last_race_time
        Rake::Task['weekly:result'].invoke(Date.today.strftime("%m%d"))
      end

    else
      puts '実行するスクリプトはありません'
    end
  end
end
