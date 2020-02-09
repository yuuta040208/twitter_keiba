class RacesController < ApplicationController
  def index
    @date_races = DateRace.
        all.
        page(params[:page]).
        per(2)

    @races = Race.where(date: @date_races.pluck(:date)).
        order(date: 'desc').
        order(:hold)

    @last_updated_at = Forecast.last.updated_at.in_time_zone('Tokyo').strftime('%H:%M')
  end

  def show
    @race = Race.find(params[:id])
    @horses = @race.horses.
        order(:umaban)
    @forecasts = @race.forecasts.
        includes(:user, :tweet).
        where('users.tanshou IS NOT NULL').
        order('users.tanshou DESC').
        page(params[:page])

    @my_forecasts = my_forecasts
  end


  private

  def tanshou_horse
    tanshou_forecasts = @race.forecasts.
        includes(:user, :tweet).
        where(user_id: User.tanshou_masters.pluck(:id)).
        where('forecasts.honmei IS NOT NULL').
        order('users.tanshou DESC')
    tanshou_honmeis = tanshou_forecasts.pluck(:honmei)

    tanshou_honmeis.present? ? tanshou_honmeis : []
  end

  def fukushou_horse
    fukushou_forecasts = @race.forecasts.
        includes(:user, :tweet).
        where(user_id: User.fukushou_masters.pluck(:id)).
        where('forecasts.honmei IS NOT NULL').
        order('users.fukushou DESC')
    fukushou_honmeis = fukushou_forecasts.pluck(:honmei)

    fukushou_honmeis.present? ? fukushou_honmeis : []
  end

  def my_forecasts
    horses = tanshou_horse + fukushou_horse
    forecasts = horses.uniq.map {|horse| {name: horse, count: horses.count(horse)}}

    # 一人しか予想していないものは確度が低いため除外する
    forecasts.reject {|forecast| forecast[:count] == 1}.sort {|a, b| a[:count] <=> b[:count]}.reverse
  end
end
