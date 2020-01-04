class RacesController < ApplicationController
  def index
    @races = Race.includes(:forecasts).all.order(date: 'desc')
  end

  def show
    @race = Race.includes(:horses).find_by(id: params[:id])
    @forecasts = @race.forecasts.includes(:tweet)
  end
end
