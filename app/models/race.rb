class Race < ApplicationRecord
  has_many :horses
  has_many :tweets
  has_many :forecasts
end
