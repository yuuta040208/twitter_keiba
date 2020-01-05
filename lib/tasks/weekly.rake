namespace :weekly do
  desc "タスクを全て実行"
  task :all, ['date'] => :environment do |task, args|
    date = args['date']

    Rake::Task['netkeiba:scrape_race'].invoke(date)
    Rake::Task['netkeiba:scrape_horse'].invoke(date)
    Rake::Task['twitter:search'].invoke(date)
    Rake::Task['scoring:create'].invoke(date)
  end

  desc "スクレイピングのみ実行"
  task :scrape, ['date'] => :environment do |task, args|
    date = args['date']

    Rake::Task['netkeiba:scrape_race'].invoke(date)
    Rake::Task['netkeiba:scrape_horse'].invoke(date)
  end

  desc "ツイート検索のみ実行"
  task :tweet, ['date'] => :environment do |task, args|
    date = args['date']

    Rake::Task['twitter:search'].invoke(date)
    Rake::Task['scoring:create'].invoke(date)
  end
end
