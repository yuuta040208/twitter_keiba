class RacesController < ApplicationController
  def index
    @races = Race.includes(:forecasts).all.order(date: 'desc').order(:hold)
  end

  def show
    @race = Race.find(params[:id])
    @horses = @race.horses.order(:umaban)
    @forecasts = @race.forecasts.includes(:user, :tweet).order('users.point DESC').page(params[:page])

    if params[:search].present?
      @forecasts = @forecasts.search(params[:search])
    end
  end
end
