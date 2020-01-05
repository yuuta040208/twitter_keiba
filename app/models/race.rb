class Race < ApplicationRecord
  has_many :horses, dependent: :destroy
  has_many :tweets, dependent: :destroy
  has_many :forecasts, dependent: :destroy
end
