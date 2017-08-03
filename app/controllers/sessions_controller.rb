# Session controller
class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    remember_user user
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  def remember_user user
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == "1" ? remember(user) : forget(user)
      redirect_to user
    else
      flash.now[:danger] = t("sessions.invalid")
      render :new
    end
  end
end
