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

    @tanshou_horse = tanshou_horse
    @fukushou_horse = fukushou_horse

    @my_forecasts = my_forecasts
  end


  private

  def tanshou_horse
    tanshou_forecasts = @race.forecasts.
        includes(:user, :tweet).
        where(user_id: User.tanshou_masters.pluck(:id)).
        order('users.tanshou DESC')
    tanshou_honmeis = tanshou_forecasts.pluck(:honmei)

    if tanshou_honmeis.empty?
      return []
    end

    # tanshou_counts = tanshou_honmeis.uniq.map {|tanshou_honmei| tanshou_honmeis.count(tanshou_honmei)}
    # if tanshou_counts.count(tanshou_counts.max) != 1 || tanshou_counts.max <= 1
    #   return nil
    # end
    #
    # tanshou_honmeis.uniq[tanshou_counts.index(tanshou_counts.max)]
    tanshou_honmeis
    # tanshou_honmeis.uniq.map{|tanshou_honmei| {name: tanshou_honmei, count: tanshou_honmeis.count(tanshou_honmei)}}
  end

  def fukushou_horse
    fukushou_forecasts = @race.forecasts.
        includes(:user, :tweet).
        where(user_id: User.fukushou_masters.pluck(:id)).
        order('users.fukushou DESC')
    fukushou_honmeis = fukushou_forecasts.pluck(:honmei)

    if fukushou_honmeis.empty?
      return []
    end

    # fukushou_counts = fukushou_honmeis.uniq.map {|fukushou_honmei| fukushou_honmeis.count(fukushou_honmei)}
    # if fukushou_counts.count(fukushou_counts.max) != 1 || fukushou_counts.max <= 1
    #   return nil
    # end
    #
    # fukushou_honmeis.uniq[fukushou_counts.index(fukushou_counts.max)]
    fukushou_honmeis
  end

  def my_forecasts
    horses = tanshou_horse + fukushou_horse
    forecasts = horses.uniq.map {|horse| {name: horse, count: horses.count(horse)}}

    # 一人しか予想していないものは確度が低いため除外する
    forecasts = forecasts.reject {|forecast| forecast[:count] == 1}
    forecasts = forecasts.sort {|a, b| a[:count] <=> b[:count]}.reverse

    forecasts
  end
end
