module RacesHelper
  def date_format(str)
    return str if str.length != 8
    str.dup.insert(4, '/').insert(7, '/')
  end

  def race_number(text)
    text.delete("^0-9").to_i
  end

  def horse_color(sum, number)
    index = Settings[:index][sum][number]
    background_color = Settings[:color][index]
    text_color = background_color == 'black' || background_color == 'red' || background_color == 'blue' ? 'white' : 'black'

    "background-color: #{background_color}; color: #{text_color};"
  end

  def horse_mark(forecast, horse_name)
    case horse_name
    when forecast.honmei then
      '◎'
    when forecast.taikou then
      '◯'
    when forecast.tanana then
      '▲'
    when forecast.renka then
      '△'
    else
      ''
    end
  end
end
