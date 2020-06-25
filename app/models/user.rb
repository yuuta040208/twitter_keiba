class User < ApplicationRecord
  RETURN_RATE_ALL = 1
  RETURN_RATE_PROFESSIONAL = 2
  RETURN_RATE_MASTER = 3

  has_many :tweets
  has_many :forecasts

  def self.search(search)
    return self.all unless search
    self.where('users.name LIKE ?', "%#{search}%")
  end

  def veteran?
    forecasts.size >= 5
  end

  def return_rate(bet_type)
    return unless [:win, :place].include?(bet_type)

    if bet_type == :win
      (tanshou || 0) / forecasts.size
    else
      (fukushou || 0) / forecasts.size
    end
  end

  def hit_rate(bet_type)
    return unless [:win, :place].include?(bet_type)

    if bet_type == :win
      hits = forecasts.includes(:hit).map { |forecast| forecast.hit.present? && forecast.hit.honmei_tanshou.present? }
      hits.count(true) * 100 / forecasts.size
    else
      hits = forecasts.includes(:hit).map { |forecast| forecast.hit.present? && forecast.hit.honmei_fukushou.present? }
      hits.count(true) * 100 / forecasts.size
    end
  end
end
