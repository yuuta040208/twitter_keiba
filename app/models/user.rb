class User < ApplicationRecord
  RETURN_RATE_ALL = 0
  RETURN_RATE_PROFESSIONAL = 90
  RETURN_RATE_MASTER = 100

  VETERAN = 5

  has_many :tweets
  has_many :forecasts
  has_one :user_stat
  has_one :stat
  has_one :taikou_user_stat
  has_one :tanana_user_stat
  has_one :renka_user_stat

  def self.search(search)
    return self.all unless search
    self.where('users.name LIKE ?', "%#{search}%")
  end

  def self.rate_users(race_id, return_rate = RETURN_RATE_PROFESSIONAL, forecast_count = VETERAN)
    users = self.joins(:forecasts)
                .includes(:forecasts)
                .includes(stat: :honmei_stat)
                .where(forecasts: { race_id: race_id })
    users.select do |user|
      user.stat.forecast_count >= forecast_count &&
          (user.stat.honmei_stat.win_return_rate >= return_rate || user.stat.honmei_stat.place_return_rate )
    end
  end
end
