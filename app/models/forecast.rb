class Forecast < ApplicationRecord
  belongs_to :tweet
  belongs_to :race
end
