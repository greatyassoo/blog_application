require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  test "should get list" do
    get comments_list_url
    assert_response :success
  end

  test "should get create" do
    get comments_create_url
    assert_response :success
  end

  test "should get update" do
    get comments_update_url
    assert_response :success
  end

  test "should get destroy" do
    get comments_destroy_url
    assert_response :success
  end

  test "should get search" do
    get comments_search_url
    assert_response :success
  end
end
