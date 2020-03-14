class Race < ApplicationRecord
  default_scope { where('races.id >= ?', 55) }

  has_many :horses, dependent: :destroy
  has_many :tweets, dependent: :destroy
  has_many :forecasts, dependent: :destroy
  has_many :hits, dependent: :destroy
  has_one :result, dependent: :destroy

  def today_forecasts(return_rate)
    user_ids = []
    User.includes(:forecasts).where(id: forecasts.pluck(:user_id)).each do |user|
      if return_rate == User::RETURN_RATE_PROFESSIONAL
        tanshou_rate = user.tanshou.to_f / user.forecasts.size
        fukushou_rate = user.fukushou.to_f / user.forecasts.size
        user_ids << user.id if 100.0 <= tanshou_rate || 100.0 <= fukushou_rate
      elsif return_rate == User::RETURN_RATE_MASTER
        tanshou_rate = user.tanshou.to_f / user.forecasts.size
        fukushou_rate = user.fukushou.to_f / user.forecasts.size
        user_ids << user.id if 200.0 <= tanshou_rate || 200.0 <= fukushou_rate
      else
        user_ids << user.id
      end
    end

    Forecast.includes(:user, :tweet).where(race_id: id, user_id: user_ids.uniq.compact)
  end

  def past_forecasts(return_rate)
    if return_rate == User::RETURN_RATE_ALL
      return Forecast.includes(:user, :tweet).where(race_id: id)
    end

    users = {}
    user_ids = []
    past_races = Race.where('date::int < ?', date)
    Hit.includes(forecast: :user).where(race_id: past_races.pluck(:id)).each do |hit|
      user_id = hit.forecast.user.id
      if users[user_id].present?
        users[user_id][:tanshou] = users[user_id][:tanshou] + (hit.honmei_tanshou || 0)
        users[user_id][:fukushou] = users[user_id][:fukushou] + hit.honmei_fukushou
        users[user_id][:count] = users[user_id][:count] + 1
      else
        users[user_id] = { tanshou: hit.honmei_tanshou || 0, fukushou: hit.honmei_fukushou, count: 1}
      end
    end

    users.each do |key, value|
      users[key] = {
          tanshou: (value[:tanshou].to_f / (value[:count] * 100) * 100).round(2),
          fukushou: (value[:fukushou].to_f / (value[:count] * 100) * 100).round(2)
      }
      if return_rate == User::RETURN_RATE_PROFESSIONAL
        user_ids << key if 100.0 <= value[:tanshou] || 100.0 <= value[:fukushou]
      elsif return_rate == User::RETURN_RATE_MASTER
        user_ids << key if 200.0 <= value[:tanshou] || 200.0 <= value[:fukushou]
      else
        user_ids << key
      end
    end

    Forecast.includes(:user, :tweet).where(race_id: id, user_id: user_ids.uniq.compact)
  end
end
