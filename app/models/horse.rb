class Horse < ApplicationRecord
  belongs_to :race
  has_many :odds
end
