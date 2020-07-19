namespace :weekly do
  desc "タスクを全て実行"
  task :all, ['date'] => :environment do |task, args|
    date = args['date']

    Rake::Task['scrape:race'].invoke(date)
    Rake::Task['scrape:horse'].invoke(date)
    Rake::Task['twitter:search'].invoke(date)
    Rake::Task['scoring:create'].invoke(date)
  end

  desc "スクレイピングのみ実行"
  task :scrape, ['date'] => :environment do |task, args|
    date = args['date']

    Rake::Task['scrape:race'].invoke(date)
    Rake::Task['scrape:horse'].invoke(date)
  end

  desc "ツイート検索のみ実行"
  task :tweet, ['date'] => :environment do |task, args|
    date = args['date']

    Rake::Task['twitter:search'].invoke(date)
    Rake::Task['scoring:create'].invoke(date)
  end

  desc "オッズ更新のみ実行"
  task :odds, ['date'] => :environment do |task, args|
    date = args['date']

    Rake::Task['scrape:odds'].invoke(date)
  end

  desc "レース後処理のみ実行"
  task :result, ['date'] => :environment do |task, args|
    date = args['date']

    Rake::Task['scrape:result'].invoke(date)
    Rake::Task['scoring:hit'].invoke(date)
    Rake::Task['scoring:user_odds'].invoke(date)
    Rake::Task['scoring:user_stats'].invoke(date)
  end
end
