desc "This task is called by the Heroku scheduler add-on"
task :scheduler do
  races = Race.where(date: Date.today.strftime("%Y%m%d"))

  if races.blank?
    puts 'レース情報を取得'
    Rake::Task['scrape:race'].invoke(date)

  else
    if races.first.horses.blank?
      puts '競走馬情報を取得'
      Rake::Task['scrape:horse'].invoke(date)

    else

      now = Time.now.strftime("%H%M")
      now = now.end_with?('0') ? now.slice(1..-1) : now
      if races.last.time.to_i < now.to_i
        puts 'ツイートを検索'
      end
    end
  end
end
