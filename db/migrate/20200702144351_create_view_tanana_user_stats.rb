class CreateViewTananaUserStats < ActiveRecord::Migration[6.0]
  def up
    ActiveRecord::Base.connection.execute('
      CREATE VIEW tanana_user_stats AS
      SELECT
        users.id as user_id,
        count(forecasts.id) as forecasts_count,
        (coalesce(users.total_win_tanana, 0) / count(forecasts.id)) as return_rate_win,
        (coalesce(users.total_place_tanana, 0) / count(forecasts.id)) as return_rate_place,
        (
          select round(count(sub_f) * 1.0 / count(forecasts.id), 2) * 100 from forecasts sub_f
          inner join hits h on h.forecast_id = sub_f.id
          where h.tanana_fukushou is not null and sub_f.user_id = users.id
        ) as hit_rate_place,
        (
          select round(count(sub_f) * 1.0 / count(forecasts.id), 2) * 100 from forecasts sub_f
          inner join hits h on h.forecast_id = sub_f.id
          where h.tanana_tanshou is not null and sub_f.user_id = users.id
        ) as hit_rate_win
        FROM users
        inner join forecasts on forecasts.user_id = users.id
        group by users.id;
    ')
  end

  def down
    ActiveRecord::Base.connection.execute('DROP VIEW tanana_user_stats;')
  end
end
