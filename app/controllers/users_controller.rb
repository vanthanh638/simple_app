# User controller
class UsersController < ApplicationController
  def show
    # find user
    @user = User.find_by id: params[:id]
    if @user.nil?
      flash[:danger] = t("users.new.user_nil")
      redirect_to signup_path
    else
      flash.now[:success] = t("users.new.flash")
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = t("users.new.flash")
      redirect_to @user
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end
end
