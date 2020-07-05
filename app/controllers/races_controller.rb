class RacesController < ApplicationController
  def index
    @date_races = DateRace.all.page(params[:page]).per(2)
    @races = Race.where(date: @date_races.pluck(:date))
                 .order(date: 'desc')
                 .order(:hold)
    @last_updated_at = Forecast.last.updated_at.in_time_zone('Tokyo').strftime('%Y/%m/%d %H:%M')
  end

  def show
    @race = Race.find(params[:id])
    @horses = @race.horses.includes(:odds).order(:umaban)

    @return_rate = if params[:return_rate].nil?
                     User::RETURN_RATE_PROFESSIONAL
                   else
                     params[:return_rate].to_i
                   end

    forecasts = @race.cache_forecasts(@return_rate)

    @honmeis, @taikous, @tananas, @renkas = forecasts.pluck(:honmei, :taikou, :tanana, :renka).transpose
    @twitter_rates = @race.calculate_twitter_rates(@honmeis, @taikous, @tananas, @renkas, @return_rate)
    @forecasts = forecasts.joins(user: :user_stat).includes(user: :user_stat).order('users.tanshou DESC NULLS LAST').page(params[:page])
  end

  def tweets
    per = request.from_smartphone? ? 9 : 30
    @race = Race.find(params[:race_id])
    @forecasts = @race.cache_forecasts(User::RETURN_RATE_PROFESSIONAL)
    @honmeis = @forecasts.pluck(:honmei)

    if params[:horse_number]
      horse_names = @race.horses.where(horses: {umaban: params[:horse_number]}).pluck(:name)
      @forecasts = @forecasts.where(honmei: horse_names) if horse_names.present?
    end

    @forecasts = @forecasts.order('users.tanshou DESC NULLS LAST').page(params[:page]).per(per)
  end

  def bets
    @race = Race.find(params[:race_id])
    forecasts = @race.cache_forecasts(User::RETURN_RATE_PROFESSIONAL)

    honmeis = forecasts.pluck(:honmei)
    taikous = forecasts.pluck(:taikou)
    tananas = forecasts.pluck(:tanana)
    renkas = forecasts.pluck(:renka)

    twitter_rates = @race.calculate_twitter_rates(honmeis, taikous, tananas, renkas, User::RETURN_RATE_PROFESSIONAL)
    @my_forecasts = my_forecast(twitter_rates, @race)
  end

  def recommendations
    @race = Race.find(params[:race_id])

    @user_collection = Rails.cache.fetch("cache_recommendations_#{@race.id}", expired_in: 10.minute) do
      UserCollection.new(@race.tweets.pluck(:user_id))
    end
  end

  def odds
    @race = Race.find(params[:race_id])
    @labels = @race.horses.first.odds.order(:created_at).pluck(:created_at).map {|a| a.in_time_zone('Tokyo').strftime('%H:%M')}
  end


  private

  def my_forecast(rates, race)
    horses = race.horses
    horse_info = rates.map.with_index(1) do |rate, i|
      horse = horses.find_by(umaban: i)
      odds = horse.odds.present? ? horse.odds.last.win : horse.win
      weight = if odds <= 10
                 1 + (10 - odds) * 0.020
               else
                 1 - (odds / 10) * 0.04
               end

      {
          number: i,
          name: horse.name,
          odds: odds,
          rate: rate * weight
      }
    end

    horse_info.sort_by {|a| a[:rate]}.reverse
  end
end
