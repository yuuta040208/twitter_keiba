class User < ApplicationRecord
  has_many :tweets
  has_many :forecasts

  def self.search(search)
    return self.all unless search
    self.where('name LIKE ?', "%#{search}%")
  end
end
