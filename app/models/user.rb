class User < ApplicationRecord
  RETURN_RATE_ALL = 1
  RETURN_RATE_PROFESSIONAL = 2
  RETURN_RATE_MASTER = 3

  has_many :tweets
  has_many :forecasts

  attr_accessor :sum

  def self.search(search)
    return self.all unless search
    self.where('name LIKE ?', "%#{search}%")
  end

  def veteran?
    forecasts.size >= 5
  end

  def return_rate(bet_type)
    return unless [:win, :place].include?(bet_type)

    if bet_type == :win
      tanshou || 0 / forecasts.size
    else
      fukushou || 0 / forecasts.size
    end
  end

  def hit_rate(bet_type)
    return unless [:win, :place].include?(bet_type)

    if bet_type == :win
      hits = forecasts.includes(race: :result).map do |forecast|
        next if forecast.race.result.nil?

        forecast.honmei == forecast.race.result.first_horse
      end

      hits.count(true) * 100 / forecasts.size
    else
      hits = forecasts.includes(race: :result).map do |forecast|
        result = forecast.race.result
        next if result.nil?

        [result.first_horse, result.second_horse, result.third_horse].include?(forecast.honmei)
      end

      hits.count(true) * 100 / forecasts.size
    end
  end

  def betted_average_odds
    odds = forecasts.includes(race: :horses).map do |forecast|
      horses = forecast.race.horses
      [horses.find_by(name: forecast.honmei)&.win, horses.find_by(name: forecast.taikou)&.win]
    end

    odds.flatten.compact.sum / odds.size
  end
end
