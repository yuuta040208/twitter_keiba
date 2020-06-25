class UsersController < ApplicationController
  def index
    select_columns = User.column_names.map { |column| "users.#{column}" }
    select_columns << 'count(forecasts.id) as forecasts_count'
    select_columns << '(coalesce(users.tanshou, 0) / count(forecasts.id)) as return_rate_win'
    select_columns << '(coalesce(users.fukushou, 0) / count(forecasts.id)) as return_rate_place'
    select_columns << '
      (select round(count(sub_f) * 1.0 / count(forecasts.id), 2) * 100 from forecasts sub_f
      inner join hits h on h.forecast_id = sub_f.id
      where h.honmei_fukushou is not null and sub_f.user_id = users.id) as hit_rate_place
    '
    select_columns << '
      (select round(count(sub_f) * 1.0 / count(forecasts.id), 2) * 100 from forecasts sub_f
      inner join hits h on h.forecast_id = sub_f.id
      where h.honmei_tanshou is not null and sub_f.user_id = users.id) as hit_rate_win
    '
    order_columns = [:forecasts_count, :return_rate_win, :return_rate_place, :hit_rate_win, :hit_rate_place]

    @users = User.where
                 .not(tanshou: nil)
                 .joins(:forecasts)
                 .preload(:forecasts)
                 .group('users.id')
                 .having('count(forecasts.id) >= 5')
                 .select(select_columns)
                 .page(params[:page])

    if params[:order].present? && order_columns.include?(params[:order].to_sym)
      @users = @users.order("#{params[:order]} desc")
    else
      @users = @users.order('count(forecasts.id) desc')
    end

    if params[:search].present?
      @users = @users.search(params[:search])
    end
  end

  def show
    @user = User.find(params[:id])
    @forecasts = @user.forecasts.
        includes(race: :result).
        includes(:tweet).
        order(created_at: 'desc')
    @forecast_size = @forecasts.map { |forecast| forecast.race.result }.compact.size
  end
end
