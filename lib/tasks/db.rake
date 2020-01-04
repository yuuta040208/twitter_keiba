namespace :db do
  desc "データベースの中身を空にする"
  task :truncate => :environment do |task, args|
    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE races;'
    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE horses;'
    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE tweets;'
    ActiveRecord::Base.connection.execute 'TRUNCATE TABLE forecasts;'
  end
end
