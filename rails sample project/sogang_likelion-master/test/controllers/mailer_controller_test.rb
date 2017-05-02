require 'test_helper'

class MailerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get mailer_index_url
    assert_response :success
  end

end
