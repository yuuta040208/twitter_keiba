class Tweet < ApplicationRecord
  belongs_to :race
  belongs_to :user
  has_one :forecast
end
