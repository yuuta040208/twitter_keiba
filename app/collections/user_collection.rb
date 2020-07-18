class UserCollection
  attr_reader :win_kenjitsu_user, :place_kenjitsu_user, :win_ippatsu_user, :place_ippatsu_user

  def initialize(user_ids)
    @win_kenjitsu_user = kenjitsu(user_ids, :win)
    @place_kenjitsu_user = kenjitsu(user_ids, :place)
    @win_ippatsu_user = ippatsu(user_ids, :win)
    @place_ippatsu_user = ippatsu(user_ids, :place)
  end


  private

  def kenjitsu(user_ids, bet_type)
    User.includes(stat: :honmei_stat)
        .where(id: user_ids)
        .where('users.average_win < 10')
        .where('stats.forecast_count >= 5')
        .order("honmei_stats.#{bet_type}_hit_rate desc")
        .first
  end

  def ippatsu(user_ids, bet_type)
    User.includes(stat: :honmei_stat)
        .where(id: user_ids)
        .where('users.average_win >= 10')
        .where('forecast_count >= 5')
        .order("honmei_stats.#{bet_type}_return_rate desc")
        .first
  end
end