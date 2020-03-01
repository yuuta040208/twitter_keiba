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

    user_ids = []
    User.includes(:forecasts).where(id: @race.forecasts.pluck(:user_id)).each do |user|
      next if user.tanshou.nil? || user.fukushou.nil?
      tanshou_rate = user.tanshou.to_f / user.forecasts.size
      fukushou_rate = user.fukushou.to_f / user.forecasts.size
      user_ids << user.id if tanshou_rate >= 100.0 || fukushou_rate >= 100.0
    end

    @forecasts = Forecast.includes(:user, :tweet).where(race_id: @race.id, user_id: user_ids.uniq.compact).
        order('users.tanshou DESC').
        page(params[:page])
  end
end
