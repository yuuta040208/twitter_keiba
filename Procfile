release: $(bundle exec rake db:migrate; cd config; echo $RAILS_MASTER_KEY > master.key)
web: bundle exec rails server -p $PORT