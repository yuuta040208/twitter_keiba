class RacesController < ApplicationController
  def index
    @date_races = DateRace.
        all.
        page(params[:page]).
        per(2)

    @races = Race.where(date: @date_races.pluck(:date)).
        order(date: 'desc').
        order(:hold)

    @last_updated_at = Forecast.last.updated_at.in_time_zone('Tokyo').strftime('%Y/%m/%d %H:%M')
  end

  def show
    @race = Race.find(params[:id])
    @horses = @race.horses.
        order(:umaban)

    @return_rate = if params[:return_rate].nil?
                     User::RETURN_RATE_PROFESSIONAL
                   else
                     params[:return_rate].to_i
                   end

    forecasts = if @race.result.present?
                  cache_forecasts
                else
                  @race.today_forecasts(@return_rate)
                end

    @honmeis = forecasts.pluck(:honmei)
    @taikous = forecasts.pluck(:taikou)
    @tananas = forecasts.pluck(:tanana)
    @renkas = forecasts.pluck(:renka)

    @twitter_rates = calculate_twitter_rates(@horses, @honmeis, @taikous, @tananas, @renkas)

    @forecasts = forecasts.order('users.tanshou DESC').page(params[:page])
  end


  private

  def calculate_twitter_rates(horses, honmeis, taikous, tananas, renkas)
    scores = []
    horses.each do |horse|
      scores << (honmeis.count(horse.name) * 5) + (taikous.count(horse.name) * 3) + (tananas.count(horse.name) * 2) + (renkas.count(horse.name) * 1)
    end

    twitter_odds = scores.map {|a| a.zero? ? 0 : (scores.sum.to_f / a * 0.8).round(2)}
    horses.pluck(:odds).map.with_index {|a, i| (twitter_odds[i] / a).round(2)}
  end

  def cache_forecasts
    Rails.cache.fetch("cache_forecasts_#{@race.id}_#{@return_rate}", expired_in: 60.minutes) do
      @race.past_forecasts(@return_rate)
    end
  end
end
