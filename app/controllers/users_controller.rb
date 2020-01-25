class UsersController < ApplicationController
  def index
    @users = User.order(point: 'desc').page(params[:page])

    if params[:search].present?
      @users = @users.search(params[:search])
    end

    @users.each do |user|
      sum = 0
      count = 0

      user.forecasts.includes(race: :result).each do |forecast|
        race = forecast.race
        result = race.result

        if result.present?
          if forecast.honmei == result.first_horse
            sum += Horse.find_by(name: forecast.honmei).odds * 100
          end

          count += 100
        end
      end

      user.sum = (sum / count * 100).to_i
    end
  end

  def show
    @user = User.find(params[:id])
    @forecasts = @user.forecasts.
        includes(race: :result).
        includes(:tweet).
        order(created_at: 'desc')
  end
end
