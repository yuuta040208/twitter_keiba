namespace :db do
  desc "データベースの中身を空にする"
  task :truncate => :environment do |task, args|
    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE races;'
    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE horses;'
    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE tweets;'
    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE forecasts;'
  end

  desc "指定した日付のデータを削除する"
  task :destroy, ['date'] => :environment do |task, args|
    Race.where(date: "#{Date.today.year}#{args['date']}").each(&:destroy)
  end
end
