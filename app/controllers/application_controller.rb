class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception 
  before_action :get_user

  private
  def get_user
    @user = current_user
    @is_logged_in = user_signed_in?
    @is_user = @is_logged_in && @user.role.upcase == 'USER'
    @is_admin = @is_logged_in && @user.role.upcase == 'ADMIN'
  end

  def auth_admin
    redirect_to root_url if @is_admin == false
  end

  def auth_user
    redirect_to root_url if @is_user == false
  end
end
