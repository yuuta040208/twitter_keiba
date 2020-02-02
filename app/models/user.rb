class User < ApplicationRecord
  MASTER_COUNT = 5 # 何レース以上予想したか
  MASTER_RATE = 80 # 回収率は何パーセント以上か

  has_many :tweets
  has_many :forecasts

  attr_accessor :sum

  def self.search(search)
    return self.all unless search
    self.where('name LIKE ?', "%#{search}%")
  end

  def self.tanshou_masters
    ids = self.joins(:forecasts).
        group(:id).
        having('count(users.id) > ?', MASTER_COUNT).
        pluck(:id)

    self.includes(:forecasts).where(id: ids).select do |tanshou_master|
      tanshou = tanshou_master.tanshou || 0
      tanshou / tanshou_master.forecasts.size > MASTER_RATE
    end
  end

  def self.fukushou_masters
    ids = self.joins(:forecasts).
        group(:id).
        having('count(users.id) > ?', MASTER_COUNT).
        pluck(:id)

    self.includes(:forecasts).where(id: ids).select do |fukushou_master|
      fukushou = fukushou_master.fukushou || 0
      fukushou / fukushou_master.forecasts.size > MASTER_RATE
    end
  end
end
