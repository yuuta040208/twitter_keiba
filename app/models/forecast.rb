class Forecast < ApplicationRecord
  belongs_to :tweet
  belongs_to :race
  belongs_to :user

  def self.search(search)
    return self.all unless search
    self.where('name LIKE ?', "%#{search}%")
  end
end
