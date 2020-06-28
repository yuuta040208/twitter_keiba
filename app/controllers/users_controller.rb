class UsersController < ApplicationController
  def index
    @user_stats = UserStat.includes(:user).where('forecasts_count >= 5').page(params[:page])

    @user_stats = if params[:order].present? && UserStat.stat_columns.include?(params[:order].to_sym)
                    @user_stats.order("#{params[:order]} desc")
                  else
                    @user_stats.order(forecasts_count: :desc)
                  end

    if params[:search].present?
      @user_stats = @user_stats.search(params[:search])
    end
  end

  def show
    @user_stat = UserStat.includes(:user).find_by(user_id: params[:id])
    @forecasts = Forecast.includes(race: :result)
                     .where(user_id: @user_stat.user_id)
                     .order('race_id desc')
  end
end
