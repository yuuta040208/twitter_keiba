class User < ApplicationRecord
  has_many :tweets
  has_many :forecasts
end
