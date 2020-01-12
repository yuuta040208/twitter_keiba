require 'test_helper'

class RacesControllerTest < ActionDispatch::IntegrationTest
  test "/users にアクセスできること" do
    get users_url
    assert_response :success
  end

  test "/users/{id} にアクセスできること" do
    get user_url(users(:evitch).id)
    assert_response :success
  end
end
