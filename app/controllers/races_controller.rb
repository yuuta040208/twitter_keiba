class RacesController < ApplicationController
  def index
    @races = Race.includes(:forecasts).
        order(date: 'desc').
        order(:hold)
  end

  def show
    @race = Race.find(params[:id])
    @horses = @race.horses.
        order(:umaban)
    @forecasts = @race.forecasts.
        includes(:user, :tweet).
        order('users.point DESC').
        page(params[:page])

    @tanshou_horse = tanshou_horse
    @fukushou_horse = fukushou_horse
  end


  private

  def tanshou_horse
    tanshou_forecasts = @race.forecasts.
        includes(:user, :tweet).
        where(user_id: User.tanshou_masters.pluck(:id)).
        order('users.tanshou DESC')
    tanshou_honmeis = tanshou_forecasts.pluck(:honmei)

    if tanshou_honmeis.empty?
      return nil
    end

    tanshou_counts = tanshou_honmeis.uniq.map {|tanshou_honmei| tanshou_honmeis.count(tanshou_honmei)}
    if tanshou_counts.count(tanshou_counts.max) != 1
      return nil
    end

    tanshou_honmeis.uniq[tanshou_counts.index(tanshou_counts.max)]
  end

  def fukushou_horse
    fukushou_forecasts = @race.forecasts.
        includes(:user, :tweet).
        where(user_id: User.fukushou_masters.pluck(:id)).
        order('users.fukushou DESC')
    fukushou_honmeis = fukushou_forecasts.pluck(:honmei)

    if fukushou_honmeis.empty?
      return nil
    end

    fukushou_counts = fukushou_honmeis.uniq.map {|fukushou_honmei| fukushou_honmeis.count(fukushou_honmei)}
    if fukushou_counts.count(fukushou_counts.max) != 1
      return nil
    end

    fukushou_honmeis.uniq[fukushou_counts.index(fukushou_counts.max)]
  end
end
