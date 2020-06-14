class UserCollection
  extend Forwardable

  delegate :size => @users

  def initialize(users)
    @users = User.where(id: users.pluck(:id))
  end

  def kenjitsu(bet_type)
    @users.includes(:forecasts).filter { |user| user.veteran? && user.average_win < 10.0 }.max_by { |user| user.hit_rate(bet_type) }
  end

  def ippatsu(bet_type)
    @users.includes(:forecasts).filter { |user| user.veteran? && user.average_win >= 10.0 }.max_by { |user| user.return_rate(bet_type) }
  end
end