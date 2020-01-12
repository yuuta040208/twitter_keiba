class UsersController < ApplicationController
  def index
    @users = User.all.order(point: 'desc').page(params[:page])

    if params[:search].present?
      @users = @users.search(params[:search])
    end
  end

  def show
    @user = User.find(params[:id])
    @forecasts = @user.forecasts.includes(race: :result).includes(:tweet).order(created_at: 'desc')
  end
end
