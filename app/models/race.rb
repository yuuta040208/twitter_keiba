class Race < ApplicationRecord
  default_scope { where('races.id >= ?', 55) }

  has_many :horses, dependent: :destroy
  has_many :tweets, dependent: :destroy
  has_many :forecasts, dependent: :destroy
  has_many :hits, dependent: :destroy
  has_one :result, dependent: :destroy
  has_many :odds, dependent: :destroy

  def today_forecasts(return_rate)
    user_ids = []
    User.includes(forecasts: [race: [:result]]).where(id: forecasts.pluck(:user_id)).each do |user|
      forecast_size = user.forecasts.map { |forecast| forecast.race.result }.compact.size
      if return_rate == User::RETURN_RATE_PROFESSIONAL
        tanshou_rate = user.tanshou.to_f / forecast_size
        fukushou_rate = user.fukushou.to_f / forecast_size
        user_ids << user.id if 100.0 <= tanshou_rate || 100.0 <= fukushou_rate
      elsif return_rate == User::RETURN_RATE_MASTER
        tanshou_rate = user.tanshou.to_f / forecast_size
        fukushou_rate = user.fukushou.to_f / forecast_size
        user_ids << user.id if 200.0 <= tanshou_rate || 200.0 <= fukushou_rate
      else
        user_ids << user.id
      end
    end

    forecasts.includes(:user, :tweet).where(user_id: user_ids.uniq.compact)
  end

  def past_forecasts(return_rate)
    if return_rate == User::RETURN_RATE_ALL
      return forecasts.includes(:user, :tweet)
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

    forecasts.includes(:user, :tweet).where(user_id: user_ids.uniq.compact)
  end

  def cache_forecasts(return_rate)
    if self.result.present?
      Rails.cache.fetch("cache_forecasts_#{id}_#{return_rate}", expired_in: 24.hour) do
        past_forecasts(return_rate)
      end
    else
      Rails.cache.fetch("cache_forecasts_#{id}_#{return_rate}", expired_in: 10.minute) do
        today_forecasts(return_rate)
      end
    end
  end

  def calculate_twitter_rates(honmeis, taikous, tananas, renkas, return_rate)
    Rails.cache.fetch("cache_twitter_rates_#{id}_#{return_rate}", expired_in: 10.minute) do
      scores = []
      horses.order(:umaban).each do |horse|
        scores << (honmeis&.count(horse.name) || 0 * 10) + (taikous&.count(horse.name) || 0 * 3) + (tananas&.count(horse.name) || 0 * 2) + (renkas&.count(horse.name) || 0 * 1)
      end

      twitter_odds = scores.map {|a| a.zero? ? 0 : (scores.sum.to_f / a * 0.8).round(2)}
      horses.includes(:odds).order(:umaban).map.with_index do |horse, i|
        odds = horse.odds.present? ? horse.odds.last.win : horse.win
        twitter_odds[i].zero? ? 0 : (odds / twitter_odds[i]).round(2)
      end
    end
  end

  def table_odds(bet_type)
    return [] unless [:win, :place].include?(bet_type)

    o = odds.joins(:horse).where(time: odds.pluck(:time).uniq).pluck('horses.umaban', bet_type)
    horses.pluck(:umaban).map {|i| o.select {|a| a.first == i}}.transpose.map {|a| a.select { |b| b.second > 0 }.sort_by {|b| b.second}.map.with_index(1) {|b, j| [b.first, j]}}
  end

  def graph_odds(bet_type)
    horses.includes(:odds).order(:umaban).map do |horse|
      {
          label: horse.name,
          data: horse.odds.pluck(bet_type),
          borderColor: Settings.color[horse.wakuban - 1],
          backgroundColor: 'rgba(0, 0, 0, 0)'
      }
    end
  end
end
