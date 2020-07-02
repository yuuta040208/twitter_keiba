class TaikouUserStat < ApplicationRecord
  belongs_to :user

  delegate :name, :url, to: :user, prefix: :user

  def self.stat_columns
    [:forecasts_count, :return_rate_win, :return_rate_place, :hit_rate_win, :hit_rate_place]
  end
end
