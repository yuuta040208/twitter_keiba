module ApplicationHelper
  def result_color_code(result)
    if result == 0
      '#FFBBBB'
    elsif result == 1
      '#FFDCDC'
    elsif result == 2
      '#FFEEEE'
    else
      '#FFFFFF'
    end
  end
end
