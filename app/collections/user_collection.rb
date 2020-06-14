class UserCollection
  attr_reader :win_kenjitsu_user, :place_kenjitsu_user, :win_ippatsu_user, :place_ippatsu_user

  def initialize(users)
    @users = User.where(id: users.pluck(:id))

    @win_kenjitsu_user = kenjitsu(:win)
    @place_kenjitsu_user = kenjitsu(:place)
    @win_ippatsu_user = ippatsu(:win)
    @place_ippatsu_user = ippatsu(:place)
  end


  private

  def kenjitsu(bet_type)
    @users.includes(:forecasts).filter { |user| user.veteran? && user.average_win < 10.0 }.max_by { |user| user.hit_rate(bet_type) }
  end

  def ippatsu(bet_type)
    @users.includes(:forecasts).filter { |user| user.veteran? && user.average_win >= 10.0 }.max_by { |user| user.return_rate(bet_type) }
  end
end