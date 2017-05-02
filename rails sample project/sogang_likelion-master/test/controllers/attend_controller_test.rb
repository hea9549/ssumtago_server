require 'test_helper'

class AttendControllerTest < ActionDispatch::IntegrationTest
  test "should get check" do
    get attend_check_url
    assert_response :success
  end

  test "should get create" do
    get attend_create_url
    assert_response :success
  end

  test "should get index" do
    get attend_index_url
    assert_response :success
  end

  test "should get result" do
    get attend_result_url
    assert_response :success
  end

end
