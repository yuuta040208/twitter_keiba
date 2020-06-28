class User < ApplicationRecord
  RETURN_RATE_ALL = 1
  RETURN_RATE_PROFESSIONAL = 2
  RETURN_RATE_MASTER = 3

  has_many :tweets
  has_many :forecasts
  has_one :user_stat

  def self.search(search)
    return self.all unless search
    self.where('users.name LIKE ?', "%#{search}%")
  end
end
