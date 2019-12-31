class RacesController < ApplicationController
  def index
    @races = Race.all
  end

  def show
    @race = Race.joins(:horses)
                .joins(:tweets)
                .joins(:forecasts)
                .find(params[:id])
  end
end
