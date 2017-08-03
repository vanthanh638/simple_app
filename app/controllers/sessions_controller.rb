# Session controller
class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user && user.authenticate(params[:session][:password])
      check_activate user
    else
      flash.now[:danger] = t "sessions.invalid"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  def check_activate user
    if user.activated?
      log_in user
      params[:session][:remember_me] == Settings.remember_me ? remember(user) : forget(user)
      redirect_back_or user
    else
      message  = t "sessions.activate"
      message += t "sessions.check_email"
      flash[:warning] = message
      redirect_to root_url
    end
  end
end
