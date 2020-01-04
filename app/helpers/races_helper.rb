module RacesHelper
  def date_format(str)
    return str if str.length != 8
    str.dup.insert(4, '/').insert(7, '/')
  end
end
