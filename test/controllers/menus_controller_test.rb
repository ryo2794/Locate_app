require 'test_helper'

class MenusControllerTest < ActionDispatch::IntegrationTest
  test "should get list" do
    get menus_list_url
    assert_response :success
  end

end
