class Race < ApplicationRecord
  default_scope { where('races.id >= ?', 55) }

  has_many :horses, dependent: :destroy
  has_many :tweets, dependent: :destroy
  has_many :forecasts, dependent: :destroy
  has_one :result, dependent: :destroy
end
