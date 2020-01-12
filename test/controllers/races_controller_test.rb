require 'test_helper'

class RacesControllerTest < ActionDispatch::IntegrationTest
  test "/races にアクセスできること" do
    get races_url
    assert_response :success
  end

  test "/races/{id} にアクセスできること" do
    get race_url(races(:arima_kinen).id)
    assert_response :success
  end
end
