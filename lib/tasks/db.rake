namespace :db do
  desc "データベースの中身を空にする"
  task :truncate => :environment do |task, args|
    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE races RESTART IDENTITY;'
    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE horses RESTART IDENTITY;'
    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE tweets RESTART IDENTITY;'
    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE forecasts RESTART IDENTITY;'
    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE users RESTART IDENTITY;'
  end

  desc "usersベースの中身を空にする"
  task :truncate_users => :environment do |task, args|
    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE users RESTART IDENTITY;'
  end

  desc "指定した日付のデータを削除する"
  task :destroy, ['date'] => :environment do |task, args|
    Race.where(date: "#{Date.today.year}#{args['date']}").each(&:destroy)
  end
end
