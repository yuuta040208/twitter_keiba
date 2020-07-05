class CreateViewUserStats < ActiveRecord::Migration[6.0]
  def up
    ActiveRecord::Base.connection.execute('
      CREATE VIEW user_stats AS
      SELECT
        users.id as user_id,
        count(forecasts.id) as forecasts_count,
        (coalesce(users.tanshou, 0) / case when count(forecasts.honmei) = 0 then 1 else count(forecasts.honmei) end) as return_rate_win,
        (coalesce(users.fukushou, 0) / case when count(forecasts.honmei) = 0 then 1 else count(forecasts.honmei) end) as return_rate_place,
        (
          select round(count(sub_f) * 1.0 / case when count(forecasts.honmei) = 0 then 1 else count(forecasts.honmei) end, 2) * 100 from forecasts sub_f
          inner join hits h on h.forecast_id = sub_f.id
          where h.honmei_fukushou is not null and sub_f.user_id = users.id
        ) as hit_rate_place,
        (
          select round(count(sub_f) * 1.0 / case when count(forecasts.honmei) = 0 then 1 else count(forecasts.honmei) end, 2) * 100 from forecasts sub_f
          inner join hits h on h.forecast_id = sub_f.id
          where h.honmei_tanshou is not null and sub_f.user_id = users.id
        ) as hit_rate_win
        FROM users
        inner join forecasts on forecasts.user_id = users.id
        group by users.id;
    ')
  end

  def down
    ActiveRecord::Base.connection.execute('DROP VIEW user_stats;')
  end
end
