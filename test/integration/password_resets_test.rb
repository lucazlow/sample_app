require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end
  
  test "password reset" do
    get new_password_reset_path
    assert_template 'password_resets/new'
   #無効なメールアドレス
    post password_resets_path, params: { password_reset: { email: "" } }  #controllerに無効なパラメーターを送る
    assert_not flash.empty?
    assert_template 'password_resets/new'
  #有効なメールアドレス
    post password_resets_path,
         params: { password_reset: { email: @user.email } }  #controllerに有効なパラメーターを送る
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
   #パスワード再設定のフォームテスト
    user = assigns(:user)
    #無効なメールアドレス
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    #無効なユーザー
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    #メールアドレスは有効で、トークンが無効
    get edit_password_reset_path('wrong_token', email: user.email)
    assert_redirected_to root_url
    #メールアドレス、トークンが共に有効
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    #無効なパスワードと確認パスワード
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                     user: { password:               "foobaz",
                             password_confirmation:  "berfoe" } }
    assert_select 'div#error_explanation'
    #パスワードが空
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                     user: { password:               "",
                             password_confirmation:  "" } }
    assert_select 'div#error_explanation'
    #有効なパスワードと確認パスワード
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                     user: { password:               "foobaz",
                             password_confirmation:  "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_nil user.reload[:reset_digest]
    assert_redirected_to user
  end
  
  test "expired token" do
    get new_password_reset_path
    post password_resets_path,
         params: { password_reset: { email: @user.email} }
    
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
     patch password_reset_path(@user.reset_token),
           params: { email: @user.email,
                      user: { password:               "foobaz",
                              password_confirmation:  "foobaz" } }
     assert_response :redirect
     follow_redirect!
     assert_match "expired", response.body
  end
  
end
