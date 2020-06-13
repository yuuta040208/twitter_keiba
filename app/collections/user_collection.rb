class UserCollection
  extend Forwardable

  delegate :size => @users

  def initialize(users)
    @users = users
  end

  def kenjitsu(bet_type)
    @users.filter { |user| user.veteran? && user.betted_average_odds < 10.0 }.max_by { |user| user.hit_rate(bet_type) }
  end

  def ippatsu(bet_type)
    @users.filter { |user| user.veteran? && user.betted_average_odds >= 10.0 }.max_by { |user| user.return_rate(bet_type) }
  end
end