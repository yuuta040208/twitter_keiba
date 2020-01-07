release: bundle exec rake db:migrate && echo $SECRET_KEY_BASE > config/master.key
web: bundle exec rails server -p $PORT