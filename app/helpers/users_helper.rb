module UsersHelper
  def result_color(result)
    if result == 0
      'background-color: #FFBBBB'
    elsif result == 1
      'background-color: #FFDCDC'
    elsif result == 2
      'background-color: #FFEEEE'
    else
      'background-color: #FFFFFF'
    end
  end
end
