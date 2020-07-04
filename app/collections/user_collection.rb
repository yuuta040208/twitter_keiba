class UserCollection
  attr_reader :win_kenjitsu_user_stat, :place_kenjitsu_user_stat, :win_ippatsu_user_stat, :place_ippatsu_user_stat

  def initialize(user_ids)
    @win_kenjitsu_user_stat = kenjitsu(user_ids, :win)
    @place_kenjitsu_user_stat = kenjitsu(user_ids, :place)
    @win_ippatsu_user_stat = ippatsu(user_ids, :win)
    @place_ippatsu_user_stat = ippatsu(user_ids, :place)
  end


  private

  def kenjitsu(user_ids, bet_type)
    UserStat.includes(:user)
        .joins(:user)
        .where(user_id: user_ids)
        .where('users.average_win < 10')
        .where('forecasts_count >= 5')
        .order("hit_rate_#{bet_type} desc")
        .first
  end

  def ippatsu(user_ids, bet_type)
    UserStat.includes(:user)
        .joins(:user)
        .where(user_id: user_ids)
        .where('users.average_win >= 10')
        .where('forecasts_count >= 5')
        .order("return_rate_#{bet_type} desc")
        .first
  end
end