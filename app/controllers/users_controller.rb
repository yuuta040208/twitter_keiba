class UsersController < ApplicationController
  def index
    @users = User.all.order(point: 'desc').page(params[:page])
  end

  def show
    @user = User.find(params[:id])
    @forecasts = @user.forecasts.includes(race: :result).includes(:tweet)
  end
end
