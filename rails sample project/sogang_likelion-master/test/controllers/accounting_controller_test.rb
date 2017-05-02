require 'test_helper'

class AccountingControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get accounting_index_url
    assert_response :success
  end

end
