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
                  @race.cache_forecasts(@return_rate)
                else
                  @race.today_forecasts(@return_rate)
                end

    @honmeis = forecasts.pluck(:honmei)
    @taikous = forecasts.pluck(:taikou)
    @tananas = forecasts.pluck(:tanana)
    @renkas = forecasts.pluck(:renka)

    @twitter_rates = @race.calculate_twitter_rates(@honmeis, @taikous, @tananas, @renkas)

    @forecasts = forecasts.order('users.tanshou DESC').page(params[:page])
  end
end
