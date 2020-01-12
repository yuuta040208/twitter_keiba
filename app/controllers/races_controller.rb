class RacesController < ApplicationController
  def index
    @races = Race.includes(:forecasts).all.order(date: 'desc').order(:name)
  end

  def show
    @race = Race.includes(:horses).find(params[:id])
    @forecasts = @race.forecasts.includes(:user, :tweet).order('users.point DESC').page(params[:page])

    if params[:search].present?
      @forecasts = @forecasts.search(params[:search])
    end
  end
end
