class Stat < ApplicationRecord
  belongs_to :user
  has_one :honmei_stat
end
