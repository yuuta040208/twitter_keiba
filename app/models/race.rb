class Race < ApplicationRecord
  default_scope { where('races.id >= ?', 55) }

  has_many :horses, dependent: :destroy
  has_many :tweets, dependent: :destroy
  has_many :forecasts, dependent: :destroy
  has_many :hits, dependent: :destroy
  has_one :result, dependent: :destroy
  has_many :odds, dependent: :destroy

  def cache_forecasts(return_rate)
    if self.result.present?
      Rails.cache.fetch("cache_forecasts_#{id}_#{return_rate}", expired_in: 24.hour) do
        rate_forecasts(return_rate)
      end
    else
      Rails.cache.fetch("cache_forecasts_#{id}_#{return_rate}", expired_in: 10.minute) do
        rate_forecasts(return_rate)
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

  def line_tweets(limit:)
    UserStat.includes(user: :tweets)
        .joins(:user)
        .where(user_id: forecasts.pluck(:user_id))
        .where('forecasts_count >= 10')
        .order('hit_rate_place desc')
        .order('hit_rate_win desc')
        .limit(limit)
        .map(&:user)
        .map {|user| user.tweets.find_by(race_id: id)}
  end


  private

  def rate_forecasts(return_rate)
    if return_rate == User::RETURN_RATE_ALL
      return forecasts.includes(:user, :tweet)
    end

    user_ids = User.rate_users(id, return_rate).pluck(:id)
    forecasts.includes(:tweet)
        .includes(user: :stat)
        .where(user_id: user_ids.compact.uniq)
        .order('stats.forecast_count DESC')
  end
end
