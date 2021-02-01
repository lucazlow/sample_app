require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = users(:michael)
  end
  
  test "layout links" do
    get root_path #ルートURL (Homeページ) にGETリクエストを送る.
    assert_template 'static_pages/home'  #正しいページテンプレートが描画されているかどうか確かめる. 
    assert_select "a[href=?]", root_path, count: 2 #Home、Help、About、Contactの各ページへのリンクが正しく動くか確かめる.
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    get contact_path
    assert_select "title", full_title("Contact")
    get signup_path
    assert_select "title", full_title("Sign up")
  end
    
  test "layout links when logged in" do
    log_in_as(@user)
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", logout_path
    assert_match  @user.following.count.to_s, response.body
    assert_match  @user.followers.count.to_s, response.body
  end
end
