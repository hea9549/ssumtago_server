require 'test_helper'

class PreviousReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @previous_report = previous_reports(:one)
  end

  test "should get index" do
    get previous_reports_url, as: :json
    assert_response :success
  end

  test "should create previous_report" do
    assert_difference('PreviousReport.count') do
      post previous_reports_url, params: { previous_report: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show previous_report" do
    get previous_report_url(@previous_report), as: :json
    assert_response :success
  end

  test "should update previous_report" do
    patch previous_report_url(@previous_report), params: { previous_report: {  } }, as: :json
    assert_response 200
  end

  test "should destroy previous_report" do
    assert_difference('PreviousReport.count', -1) do
      delete previous_report_url(@previous_report), as: :json
    end

    assert_response 204
  end
end
