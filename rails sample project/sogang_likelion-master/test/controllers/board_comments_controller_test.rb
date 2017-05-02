require 'test_helper'

class BoardCommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @board_comment = board_comments(:one)
  end

  test "should get index" do
    get board_comments_url
    assert_response :success
  end

  test "should get new" do
    get new_board_comment_url
    assert_response :success
  end

  test "should create board_comment" do
    assert_difference('BoardComment.count') do
      post board_comments_url, params: { board_comment: {  } }
    end

    assert_redirected_to board_comment_url(BoardComment.last)
  end

  test "should show board_comment" do
    get board_comment_url(@board_comment)
    assert_response :success
  end

  test "should get edit" do
    get edit_board_comment_url(@board_comment)
    assert_response :success
  end

  test "should update board_comment" do
    patch board_comment_url(@board_comment), params: { board_comment: {  } }
    assert_redirected_to board_comment_url(@board_comment)
  end

  test "should destroy board_comment" do
    assert_difference('BoardComment.count', -1) do
      delete board_comment_url(@board_comment)
    end

    assert_redirected_to board_comments_url
  end
end
