class UserStat < ApplicationRecord
  belongs_to :user

  delegate :name, :url, to: :user, prefix: :user
end
