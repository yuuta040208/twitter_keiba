class Tweet < ApplicationRecord
  belongs_to :race
  belongs_to :user
  has_one :forecast

  delegate :id, :name, to: :user, prefix: :user
end
