class Forecast < ApplicationRecord
  default_scope { joins(:race).where('races.id >= ?', 55) }

  belongs_to :tweet
  belongs_to :race
  belongs_to :user
  has_one :hit

  def self.search(search)
    return self.all unless search
    self.where('name LIKE ?', "%#{search}%")
  end
end
