require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  
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
end
