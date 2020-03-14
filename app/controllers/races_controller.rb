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

    @forecasts = if @race.result.present?
                   cache_forecasts.order('users.tanshou DESC').page(params[:page])
                 else
                   @race.today_forecasts(@return_rate).order('users.tanshou DESC').page(params[:page])
                 end
  end


  private

  def cache_forecasts
    Rails.cache.fetch("cache_forecasts_#{@race.id}_#{@return_rate}", expired_in: 60.minutes) do
      @race.past_forecasts(@return_rate)
    end
  end
end
