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
end
