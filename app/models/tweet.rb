class Tweet < ApplicationRecord
  belongs_to :race
  has_one :forecast
end
